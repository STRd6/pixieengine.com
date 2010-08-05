class Sprite < ActiveRecord::Base
  include Commentable

  has_attached_file :image,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => "sprites/:id/:style.:extension",
    :styles => {
      :medium => ["64x64>", :png],
      :thumb => ["32x32#", :png]
    }

  acts_as_archive
  acts_as_taggable
  acts_as_taggable_on :dimension

  belongs_to :user
  belongs_to :parent, :class_name => "Sprite"

  attr_accessor :broadcast, :file_base64_encoded, :frame_data, :replay_data

  MAX_LENGTH = 128
  # Limit sizes to small pixel art for now
  validates_numericality_of :width, :height, :only_integer => true, :less_than_or_equal_to => MAX_LENGTH, :greater_than => 0, :message => "is too large"

  before_validation :gather_metadata, :convert_to_io, :set_dimensions

  after_save :send_broadcast

  after_create :update_dimension_tags!, :save_replay_data

  cattr_reader :per_page
  @@per_page = 40

  scope :with_ids, lambda {|ids|
    {:conditions => {:id => ids}}
  }

  def self.data_from_path(path)
    image_list = Magick::Image.read(path)
    frame_data = []

    first_image = image_list.first

    width = first_image.columns
    height = first_image.rows

    image_list.each do |image_data|
      frame_data << image_data.get_pixels(0, 0, width, height).map do |pixel|
        Sprite.hex_color_to_rgba(pixel.to_color(Magick::AllCompliance, false, 8, true), pixel.opacity)
      end
    end

    return {
      :width => width,
      :height => height,
      :frame_data => frame_data
    }
  end

  def data
    Sprite.data_from_path(image.url)
  end

  def load_replay_data
    File.read(replay_path)
  end

  def broadcast_link
    if user
      link = create_link
      user.broadcast "Check out the sprite I made in Pixie #{link}"
    end
  end

  def add_tag(tag)
    unless tag.blank?
      self.update_attribute(:tag_list, (tags.map(&:to_s) + [tag]).join(","))
      reload
    end
  end

  def self.bulk_import_files(directory_path, tag_list=nil)
    dir = Dir.new(directory_path)

    dir.each do |file_name|
      unless file_name =~ /^\./
        next unless file_name =~ /(\.png|\.gif)\z/
        file_path = File.expand_path(file_name, directory_path)

        unless File.directory?(file_path)
          file = File.new(file_path)
          title = file_name[0...-4]
          puts title

          sprite = Sprite.new(:file => file, :title => title, :tag_list => tag_list)
          sprite.save!(:validate => false)
        end
      end
    end
  end

  def self.splice_import_from_file(path, options={})
    tile_width = options[:tile_width] || options[:tile_size] || 32
    tile_height = options[:tile_height] || options[:tile_size] || 32
    offset_x = options[:offset_x] || options[:offset] || 0
    offset_y = options[:offset_y] || options[:offset] || 0
    margin_x = options[:margin_x] || options[:margin] || 0
    margin_y = options[:margin_y] || options[:margin] || 0
    padding_x = options[:padding_x] || options[:padding] || 0
    padding_y = options[:padding_y] || options[:padding] || 0
    tags = options[:tags] || ''
    pixel_format = "RGBA"

    puts "importing #{path}"

    image = Magick::Image.read(path).first

    tile_columns = (image.columns / (tile_width + 2 * padding_x + margin_x)).floor
    tile_rows = (image.rows / (tile_height + 2 * padding_y + margin_y)).floor

    tile_rows.times do |row|
      tile_count = 0
      tile_columns.times do |col|
        pixel_data = image.export_pixels(
          offset_x + padding_x + col * (tile_width  + 2 * padding_x + margin_x),
          offset_y + padding_y + row * (tile_height + 2 * padding_y + margin_y),
          tile_width,
          tile_height,
          pixel_format
        )

        tile_image = Magick::Image.new(tile_width, tile_height)
        tile_image.import_pixels(0, 0, tile_width, tile_height, pixel_format, pixel_data)

        # Check for blank images
        trimmed_image = tile_image.trim
        if trimmed_image.rows == 1 && trimmed_image.columns == 1
          puts "discarding blank image"
          # next
        else
          sprite = Sprite.create!(:width => tile_width, :height => tile_height)
          sprite.add_tag(tags)

          tile_image.write(sprite.file_path)
          tile_count += 1
        end
      end

      puts "imported row #{row}, #{tile_count} images"
    end
  end

  def file_path
    if frames > 1
      "#{base_path}images/#{id}.gif"
    else
      "#{base_path}images/#{id}.png"
    end
  end

  def replay_path
    "#{base_path}replays/#{id}.json"
  end

  def meta_desc
    "#{tag_list.join(' ')} #{title} #{dimension_list.join(' ')} #{description}"
  end

  def migrate_image_attachment
    update_attribute(:image, File.open(file_path))
  end

  private

  def base_path
    "#{Rails.root}/public/production/"
  end

  def save_replay_data
    if replay_data
      File.open(replay_path, 'wb') do |f|
        f << replay_data
      end
    end
  end

  def gather_metadata
    if replay_data
      self.replayable = true
    end
  end

  def convert_to_io
    if file_base64_encoded
      img_data = Base64.decode64(file_base64_encoded)

      io = StringIO.new(img_data)
      io.original_filename = "image.png"
      io.content_type = "image/png"

      self.image = io
    end
  end

  def set_dimensions
    tempfile = image.queued_for_write[:original]

    unless tempfile.nil?
      dimensions = Paperclip::Geometry.from_file(tempfile)
      self.width = dimensions.width.to_i
      self.height = dimensions.height.to_i
    end
  end


  def send_broadcast
    if broadcast == "1"
      broadcast_link
    end
  end

  def update_dimension_tags!
    tags = ["#{width}x#{height}"]

    if width == height
      tags << "Square"
    end

    if width <= 32 && height <= 32
      tags << "Small"
    elsif width <= 128 && height <= 128
      tags << "Medium"
    elsif width > 128 && height > 128
      tags << "Large"
    end

    update_attribute(:dimension_list, tags.join(","))
  end

  def create_link
    Link.create(:user => user, :target => self)
  end

  def self.hex_color_to_rgba(color, opacity)
    int_opacity = (Magick::QuantumRange - opacity) / Magick::QuantumRange.to_f

    match_data = /^#([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})/.match(color)[1..3].map(&:hex)

    "rgba(#{match_data.join(',')},#{int_opacity})"
  end
end
