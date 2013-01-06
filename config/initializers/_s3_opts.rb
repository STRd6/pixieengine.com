S3_OPTS = {
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :s3_headers => {
    'Cache-Control' => 'max-age=315576000',
    'Expires' => 20.years.from_now.httpdate
  },
  :url => ':s3_alias_url'
}

if Rails.env.test?
  S3_OPTS.merge!(:s3_host_alias => "test.pixie.strd6.com")
elsif Rails.env.development?
  S3_OPTS.merge!(:s3_host_alias => "dev.pixie.strd6.com")
elsif Rails.env.production?
  S3_OPTS.merge!(:s3_host_alias => Proc.new {|attachment| "images#{attachment.instance.id % 4}.pixieengine.com" })
end
