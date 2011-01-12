S3_OPTS = {
  :storage => :s3,
  :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
}

if Rails.env.production?
  S3_OPTS.merge!(
    :s3_host_alias => "images.pixie.strd6.com",
    :url => ':s3_alias_url'
  )
end
