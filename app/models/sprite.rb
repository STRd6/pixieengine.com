class Sprite < ActiveRecord::Base
  belongs_to :user

  attr_accessor :file_base64_encoded
  attr_accessor :file

  after_save :save_file

  def json_data
    image_data = Magick::Image.read(file_path).first

    return image_data.get_pixels(0, 0, width, height).map do |pixel|
      #TODO: Handle full range of alpha
      if pixel.opacity == 0
        pixel.to_color(Magick::AllCompliance, false, 8, true)
      else
        nil
      end
    end.to_json
  end

  private
  def file_path
    "#{Rails.root}/public/production/images/#{id}.png"
  end

  def save_file
    logger.info("OTEUHEOTNUHOETNUHETNAOUH!!!@")
    if file_base64_encoded
      logger.info("SAVING: #{file_base64_encoded}")
      File.open(file_path, 'wb') do |f|
        logger.info(Base64.decode64(file_base64_encoded))
        f << Base64.decode64(file_base64_encoded)
      end
    elsif file
      logger.info("SAVING: #{file}")
      File.open(file_path, 'wb') do |f|
        f << file.read
      end
    end
  end
end
