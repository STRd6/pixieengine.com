def s3
  return @s3 if @s3

  config = YAML.load_file("#{Rails.root}/config/s3.yml")[Rails.env]

  AWS.config config

  @s3 = AWS::S3.new
end

def bucket
  s3.buckets['pixie.strd6.com']
end

def database
  "pixie_production"
end

def basename(time=Time.now)
  "#{database}_#{time.iso8601}.sql.gz"
end

namespace :backup do
  task :database do
    file = 'dump.sql.gz'
    `pg_dump #{database} -T events -T visits -T treatments -T js_errors -U postgres | gzip > #{file}`

    s3_object = bucket.objects[basename]

    s3_object.write :file => file
  end

  task :thin => :environment do
    keys = bucket.objects.map(&:key)

    items = keys.map do |key|
      year_month = key.sub(/pixie_production_(\d\d\d\d)\-(\d\d).*/, "\\1-\\2")

      [year_month, key]
    end

    groups = items.group_by do |year_month, key|
      year_month
    end

    keepers = groups.map do |key, values|
      values.sort.first
    end

    keep_keys = {}

    keepers.each do |year_month, key|
      keep_keys[key] = year_month
    end

    results = keys.each do |key|
      if keep_keys[key]
        puts "kept #{key}"
      else
        puts "deleting #{key}..."
        bucket.objects[key].delete
      end
    end
  end
end
