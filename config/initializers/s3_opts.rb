S3_OPTS = {
  :storage => :s3,
  :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
  :url => ':s3_alias_url'
}

if Rails.env.test?
  S3_OPTS.merge!(:s3_host_alias => "test.pixie.strd6.com")
elsif Rails.env.development?
  S3_OPTS.merge!(:s3_host_alias => "dev.pixie.strd6.com")
elsif Rails.env.production?
  S3_OPTS.merge!(:s3_host_alias => "images.pixie.strd6.com")
end
