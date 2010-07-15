class Sprite < ActiveRecord::Base
  has_many :favorite
  belongs_to :user

  attr_accessor :broadcast, :file, :file_base64_encoded

  before_save :gather_metadata

  after_save :save_file
  after_save :send_broadcast

  def self.data_from_url(url)
    #TODO Animations
    image_data = Magick::Image.read(url).first
    width = image_data.columns
    height = image_data.rows

    json_data = image_data.get_pixels(0, 0, width, height).map do |pixel|
      Sprite.hex_color_to_rgba(pixel.to_color(Magick::AllCompliance, false, 8, true), pixel.opacity)
    end.to_json

    return {
      :width => width,
      :height => height,
      :json_data => json_data,
    }
  end

  def json_data
    image_data = Magick::Image.read(file_path).first

    return image_data.get_pixels(0, 0, width, height).map do |pixel|
      Sprite.hex_color_to_rgba(pixel.to_color(Magick::AllCompliance, false, 8, true), pixel.opacity)
    end.to_json
  end

  def broadcast_link
    if user
      link = create_link
      user.broadcast "Check out the sprite I made in Pixie #{link}"
    end
  end

  def self.bulk_import_files(directory_path)
    dir = Dir.new(directory_path)

    dir.each do |file_name|
      unless file_name =~ /^\./
        file_path = File.expand_path(file_name, directory_path)
        puts file_path

        unless File.directory?(file_path)
          puts "T"
          file = File.new(file_path)
          sprite = Sprite.new(:file => file)
          sprite.save!
        end
      end
    end
  end

  private
  def file_path
    "#{Rails.root}/public/production/images/#{id}.png"
  end

  def save_file
    if file_base64_encoded
      File.open(file_path, 'wb') do |f|
        f << Base64.decode64(file_base64_encoded)
      end
    elsif file
      File.open(file_path, 'wb') do |f|
        f << file.read
      end
    end
  end

  def gather_metadata
    if file
      #TODO Animations
      image_data = Magick::Image.read(file.path).first

      self.width = image_data.columns
      self.height = image_data.rows
    end
  end

  def send_broadcast
    if broadcast == "1"
      broadcast_link
    end
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
