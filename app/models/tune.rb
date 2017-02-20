class Tune < ApplicationRecord
  include Commentable

  include PgSearch
  pg_search_scope :search, against: %i[title description]

  include PublicActivity::Model
  tracked only: :create, owner: :creator

  belongs_to :creator, class_name: "User", foreign_key: "user_id"
  alias_method :user, :creator

  belongs_to :parent,
    class_name: "Tune",
    inverse_of: :children
  has_many :children,
    class_name: "Tune",
    inverse_of: :parent,
    foreign_key: "parent_id"

  before_create :upload_content_to_s3, :set_editor_metadata

  attr_accessor :content, :editor

  def set_editor_metadata
    self.meta["editor"] = editor
  end

  def upload_content_to_s3
    if content
      sha = Uploader.upload_as_content_hash_to_s3(content, "application/whimsy.composer.v0+json; charset=utf-8")

      self.content_sha256 = sha
    end
  end

  def creator_thumb_url
    if creator
      creator.avatar.url(:thumb)
    else
      "/avatars/avatar_male_gray_on_light_32x32.png"
    end
  end

  def to_param
    if title.blank?
      id.to_s
    else
      "#{id}-#{title.parameterize}"
    end
  end

  def display_title
    if title == "Untitled" or title.blank?
      "Untitled ##{id}"
    else
      title
    end
  end

  def creator_name
    if creator
      creator.display_name
    else
      "Anonymous"
    end
  end

  def content_url
    # TODO: Production CDN
    "https://s3.amazonaws.com/#{ENV["S3_BUCKET"]}/data/#{content_sha256}"
  end

  def parent_gist_id
    meta["parent_gist_id"]
  end

  def self.import_all_parents
    Tune
    .where("(meta ->> 'parent_gist_id') IS NOT NULL")
    .where('parent_id IS NULL')
    .each do |tune|
      tune.import_parent
    end
  end

  def import_parent
    return if parent_id

    if parent_gist_id
      if parent_gist_id.match /A song/
        Rails.logger.info "bad parent: #{parent_id}"
        meta["bad_parent"] = true
        save
        return
      end

      parent = Tune.import_from_gist(parent_gist_id)
      if parent
        self.parent = parent
        save
      else
        meta["parent_gist_format_invalid"] = true
        save
        Rails.logger.info "Parent gist format invalid"
      end
    end
  end

  def self.import_all_gist_ids
    gist_ids = File.read("gist_ids.txt").split("\n")

    gist_ids[0...10].each do |gist_id|
      self.import_from_gist(gist_id).save
    end
  end

  def self.import_from_gist(gist_id)
    existing_tune = Tune.where(["meta ->> 'gist_id' = ?", gist_id]).first

    return existing_tune if existing_tune

    url = URI.parse("https://api.github.com/gists/#{gist_id}")
    puts url

    request = Net::HTTP::Get.new(url.to_s)
    request.add_field("Authorization", "token #{ENV['GITHUB_TOKEN']}")
    response = Net::HTTP.start(
      url.host,
      url.port,
      use_ssl: url.scheme == 'https'
    ) {|http|
      http.request(request)
    }

    gist = JSON.parse(response.body)

    begin
      gist_description = gist["description"]

      if gist_description.include? "#"
        parent_gist_id = gist_description.split("#").last
      end

      data_json = gist["files"]["data.json"]
      pattern0 = gist["files"]["pattern0.json"]
      if data_json
        content_string = data_json["content"]
        version = "v1"
      else
        content_string = pattern0["content"]
        version = "v0"
      end
    rescue
      return
    end

    sha = Uploader.upload_as_content_hash_to_s3(content_string, "application/whimsy.composer.#{version}+json; charset=utf-8")

    existing_tune = Tune.where(content_sha256: sha).first
    return existing_tune if existing_tune

    self.new({
      meta: {
        parent_gist_id: parent_gist_id,
        gist_id: gist_id,
      },
      content_sha256: sha,
      created_at: gist["created_at"],
      updated_at: gist["updated_at"],
    })

  end
end
