S3_OPTS = {
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :s3_headers => {
    'Cache-Control' => 'public, max-age=315576000',
    'Expires' => 20.years.from_now.httpdate
  },
  :s3_protocol => 'https',
  :url => ':s3_alias_url'
}

if Rails.env.test?
  S3_OPTS.merge!(:s3_host_alias => "test.pixie.strd6.com")
elsif Rails.env.development?
  S3_OPTS.merge!(
    :s3_host_alias => "s3.amazonaws.com",
    :url => ":s3_path_url"
  )
elsif Rails.env.production?
  S3_OPTS.merge!(:s3_host_alias => Proc.new {|attachment| "#{attachment.instance.id % 4}.pixiecdn.com" })
elsif Rails.env.staging?
  S3_OPTS.merge!(:s3_host_alias => "staging.pixieengine.com.s3-website-us-east-1.amazonaws.com")
end
