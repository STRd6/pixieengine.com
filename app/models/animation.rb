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
    open(data.url, 'rb') { |f| f.read }.to_json
  end

  def display_name
    if name.blank?
      "Animation #{id}"
    else
      name
    end
  end
end
