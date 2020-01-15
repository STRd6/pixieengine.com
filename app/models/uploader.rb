require "aws-sdk-s3"

module Uploader
  def self.logger
    Rails.logger
  end

  def self.upload_as_content_hash_to_s3(body, content_type)
    sha256 = Digest::SHA256.hexdigest body

    bucket = ENV["S3_BUCKET"]
    key = "data/#{sha256}"
    s3 = Aws::S3::Client.new

    begin
      object_response = s3.head_object({
        bucket: bucket,
        key: key
      })

      exists = true
    rescue Aws::S3::Errors::NotFound
      exists = false
    end

    if exists
      # Do nothing, assume it is the same
      logger.info "object found in s3 at #{bucket}/#{key}"
    else
      logger.info "writing to s3 at #{bucket}/#{key}"
      s3.put_object({
        body: body,
        bucket: bucket,
        cache_control: "public, max-age=31536000",
        content_type: content_type,
        key: key
      })
    end

    return sha256

  end
end
