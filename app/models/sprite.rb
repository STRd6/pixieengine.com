class Sprite < ActiveRecord::Base
  belongs_to :user

  attr_accessor :file_base64_encoded
  attr_accessor :file

  after_save :save_file

  def self.data_from_url(url)
    image_data = Magick::Image.read(url).first
    width = image_data.columns
    height = image_data.rows

    json_data = image_data.get_pixels(0, 0, width, height).map do |pixel|
      Sprite.hex_color_to_rgba(pixel.to_color(Magick::AllCompliance, false, 8, true), pixel.opacity)
    end.to_json

    return {
      :width => width,
      :height => height,
      :json_data => json_data,
    }
  end

  def json_data
    image_data = Magick::Image.read(file_path).first

    return image_data.get_pixels(0, 0, width, height).map do |pixel|
      Sprite.hex_color_to_rgba(pixel.to_color(Magick::AllCompliance, false, 8, true), pixel.opacity)
    end.to_json
  end

  private
  def file_path
    "#{Rails.root}/public/production/images/#{id}.png"
  end

  def save_file
    if file_base64_encoded
      File.open(file_path, 'wb') do |f|
        f << Base64.decode64(file_base64_encoded)
      end
    elsif file
      File.open(file_path, 'wb') do |f|
        f << file.read
      end
    end
  end

  def self.hex_color_to_rgba(color, opacity)
    int_opacity = (Magick::QuantumRange - opacity) / Magick::QuantumRange.to_f

    match_data = /^#([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})/.match(color)[1..3].map(&:hex)

    "rgba(#{match_data.join(',')},#{int_opacity})"
  end
end
