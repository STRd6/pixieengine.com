class Sprite < ActiveRecord::Base
  include Commentable

  include PublicActivity::Model
  tracked only: :create, owner: :user

  has_attached_file :image, S3_OPTS.merge(
    :use_timestamp => false,
    :path => "sprites/:id/:style.:content_type_extension",
    :styles => {
      :thumb => ["32x32#", :png]
    }
  )
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_attached_file :replay, S3_OPTS.merge(
    :path => "sprites/:id/replay.json",
  )
  validates_attachment_content_type :replay, :content_type => ["application/json", "text/plain"]

  acts_as_taggable
  acts_as_taggable_on :dimension, :source

  has_many :favorites, class_name: "CollectionItem", as: :item

  belongs_to :user
  belongs_to :parent,
    :class_name => "Sprite",
    :inverse_of => :children
  has_many :children,
    :class_name => "Sprite",
    :inverse_of => :parent,
    :foreign_key => "parent_id"

  attr_accessor :file_base64_encoded, :replay_data

  MAX_LENGTH = 640
  # Limit sizes to small pixel art for now
  validates_numericality_of :width, :height, :only_integer => true, :greater_than => 0, :message => "must be greater than zero"

  before_create :convert_to_io, :save_replay_data, :set_dimension_tags

  after_create :update_asset_urls

  cattr_reader :per_page
  @@per_page = 40

  scope :for_user, lambda {|user| where(:user_id => user)}

  scope :search, ->(search) {
    if search.blank?
      where(nil)
    else
      like = "%#{search}%".downcase
      where("lower(title) like ?", like)
    end
  }

  def display_name
    if title.blank?
      "Sprite #{id}"
    else
      title
    end
  end

  def add_tag(tag)
    unless tag.blank?
      self.update_attribute(:tag_list, (tag_list + [tag]).join(","))
      reload
    end
  end

  def remove_tag(tag)
    self.tag_list = self.tag_list.remove(tag)
    save
  end

  def as_json(options={})
    {
      :comments_count => comments_count,
      :description => description,
      :height => height,
      :id => id,
      :parent_id => parent_id,
      :title => display_name,
      :url => image_url,
      :user_id => user_id,
      :width => width
    }
  end

  def commentable_json
    {
      id: id,
      name: display_name,
      url: url_for(self),
      type: self.class.name.downcase,
      image: {
        :src => image_url,
        :width => width,
        :height => height,
      },
    }
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

  def migrate_replay_attachment
    if File.exists?(replay_path)
      update_attribute(:replay, File.open(replay_path))
    end
  end

  def to_param
    if title.blank?
      id.to_s
    else
      "#{id}-#{title.parameterize}"
    end
  end

  def update_s3_metadata
    (image.styles.keys + [:original]).each do |type|
      s3_object = image.s3_object(type)

      s3_object.copy_from s3_object.key, {
        :acl => :public_read,
        :cache_control => "public, max-age=315576000",
        # :expires => 20.years.from_now.httpdate, # TODO: This doesn't seem to set...
        :metadata => nil
      }
    end
  end

  def base_path
    "#{Rails.root}/public/production/"
  end

  def save_replay_data
    if replay_data
      file = Tempfile.new ["replay", ".json"], :encoding => 'ascii-8bit'
      file.write replay_data
      file.rewind

      self.replay = file
    end
  end

  def convert_to_io
    if file_base64_encoded
      img_data = Base64.decode64(file_base64_encoded)

      file = Tempfile.new ["image", ".png"], :encoding => 'ascii-8bit'
      file.write img_data
      file.rewind

      self.image = file
    end
  end

  def update_asset_urls
    image_url = image.url
    replay_url = replay.url if replay.present?

    update_columns(image_url: image_url, replay_url: replay_url)
  end

  def set_dimensions
    io = Paperclip.io_adapters.for(image)

    unless io.nil?
      dimensions = Paperclip::Geometry.from_file(io)
      self.width = dimensions.width.to_i
      self.height = dimensions.height.to_i
    end
  end

  def set_dimension_tags
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

    self.dimension_list = tags.join(',')
  end

  def suppress!
    self.suppression += 1000
    self.update_score
    self.save!
  end

  def update_score
    self.score = (comments_count + favorites_count) - suppression
  end

  def create_link
    Link.create(:user => user, :target => self)
  end

  def self.update_s3_metadata(starting_from=0)
    find_in_batches(:start => starting_from) do |group|
      group.each do |sprite|
        tries = 3
        begin
          sprite.update_s3_metadata
        rescue
          tries -= 1
          retry if tries > 0
        end
      end
    end
  end

  def self.update_score
    self.find_each do |sprite|
      sprite.update_score.save
    end
  end
end
