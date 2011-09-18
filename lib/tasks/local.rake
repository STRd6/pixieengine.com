require 'aws/s3'
include AWS::S3

namespace :db do
  DB_SLURP_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/slurp.yml")).symbolize_keys
  DATABASE = "pixie_development"
  FILE_NAME = 'dump.sql'

  task :download_from_s3 do
    Base.establish_connection!(DB_SLURP_CONFIG)

    bucket = Bucket.find 'pixie.strd6.com'
    most_recent_backup = bucket.reverse_each.first

    File.open FILE_NAME, "wb" do |file|
      file.write most_recent_backup.value
    end
  end

  task :slurp => [:download_from_s3, :drop, :create] do
    `psql -U postgres -d #{DATABASE} -f #{FILE_NAME}`
  end
end
