namespace :db do
  DATABASE = "pixie_development"
  FILE_NAME = 'dump.sql.gz'

  task :download_from_s3 do
    require 'aws/s3'
    include AWS::S3

    config = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/slurp.yml")).symbolize_keys
    Base.establish_connection!(config)

    bucket = Bucket.find 'pixie.strd6.com'
    most_recent_backup = bucket.reverse_each.first

    File.open FILE_NAME, "wb" do |file|
      file.write most_recent_backup.value
    end
  end

  task :import_from_dump do
    `gunzip -c #{FILE_NAME} | psql -U postgres -d #{DATABASE}`
  end

  task :slurp => [:download_from_s3, :drop, :create, "schema:load", :import_from_dump]
end
