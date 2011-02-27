class Animation < ActiveRecord::Base
  belongs_to :user

  has_attached_file :data, S3_OPTS.merge(
    :path => "animations/:id/data.:extension"
  )

  attr_accessor :data_string

  before_validation :handle_data

  def handle_data
    if data_string
      io = StringIO.new(data_string)

      io.original_filename = "data.json"
      io.content_type = "application/json"

      self.data = io
    end
  end

  def string_data
    open(data.url, 'rb') { |f| f.read }
  end

  def preview_urls
    data = JSON.parse(string_data)

    return if data.length == 0

    tileset = data["tileset"].map do |tile|
      tile["src"]
    end

    data["animations"].map do |animation|
      [animation["name"], tileset[animation["frames"][0]]]
    end
  end

  def display_name
    if name.blank?
      "Animation #{id}"
    else
      name
    end
  end
end
