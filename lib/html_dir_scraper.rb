require 'open-uri'

module HTMLDirScraper
  def self.gather_image_files(url)
    response = ''
    base_uri = ''

    open(url) do |f|
      base_uri = f.base_uri
      response = f.read
    end

    doc = Hpricot(response)

    (doc/"a").each do |a|
      href = a.attributes["href"]

      if href =~ /(\.png|\.gif)$/
        yield base_uri + href
      end
    end
  end

  def self.import_dir(url, options={})
    gather_image_files(url) do |file_path|
      Sprite.splice_import_from_file(file_path, options)
    end
  end
end
