require 'RMagick'

namespace :sound do
  task :generate_waveform do
    image_width = 128
    image_height = 96

    canvas = Magick::Image.new(image_width, image_height)
    gc = Magick::Draw.new
    gc.translate(0, image_height / 2)
    gc.fill('red')

    File.open(File.join(Rails.root, '/lib/file.raw')) do |file|
      channel1_data = []
      channel2_data = []
      while !file.eof?
        channel1, channel2 = file.read(4).unpack('ss')
        channel1_data.push(channel1)
        channel2_data.push(channel2)
      end

      length = channel1_data.length
      interval_size = (length / image_width).floor

      ch1_abs = channel1_data.map do |data|
        data.abs
      end

      # ch2_abs = channel2_data.map do |data|
      #   puts data
      #   #data.abs unless data.nil?
      # end

      ch1_abs_max = ch1_abs.max
      #ch2_abs_max = ch2_abs.max

      xValues = []
      yValues = []

      (0..length).each do |i|
        if i % interval_size == 0
          xValues.push(i / interval_size)
          yValues.push((channel1_data[i] / ch1_abs_max.to_f * image_height) + (image_height / 2))
        end
      end

      gc.polyline(xValues, yValues)

    end

    gc.draw(canvas)
    canvas.write('test.png')
  end
end
