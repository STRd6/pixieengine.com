namespace :backup do
  task :database do
    config = YAML.load_file("#{Rails.root}/config/s3.yml")[Rails.env]

    AWS.config config

    s3 = AWS::S3.new

    bucket = s3.buckets.create 'pixie.strd6.com'

    database = "pixie_production"
    file = 'dump.sql.gz'
    `pg_dump #{database} -T events -T visits -T treatments -T js_errors -U postgres | gzip > #{file}`

    basename = "#{database}_#{Time.now.iso8601}.sql.gz"
    s3_object = bucket.objects[basename]

    s3_object.write :file => file
  end
end
