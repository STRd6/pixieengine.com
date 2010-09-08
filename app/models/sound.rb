class Sound < ActiveRecord::Base
  include Commentable

  has_attached_file :wav,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => "sounds/:id/:style.:extension"

  validates_attachment_presence :wav

  has_attached_file :sfs,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => "sounds/:id/:style.:extension"

  validates_attachment_presence :sfs

  belongs_to :user

  def display_name
    if title.blank?
      "Sound #{id}"
    else
      title
    end
  end

  def to_param
    if title.blank?
      id
    else
      "#{id}-#{title.seo_url}"
    end
  end
end
