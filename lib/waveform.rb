class WaveformRenderer
  WIDTH  = 200
  HEIGHT = 100
  GRAPH_BACKGROUND_COLOR = "none"

  def initialize(input)
    @input = input
  end

  def render_waveform(width = WIDTH, height = HEIGHT, background_color = GRAPH_BACKGROUND_COLOR)
    buckets = fill_buckets(width, @input)

    color = "#%06x" % (rand * 0xffffff)

    gc = build_graph(buckets, width, height, color)

    canvas = Magick::Image.new(width, height) { self.background_color = background_color }
    gc.draw(canvas)

    pngfile = Paperclip::Tempfile.new(["stream", ".png"])
    pngfile.binmode

    canvas.write(pngfile.path)
  end

private
  def fill_buckets(width, file)
    buckets = NArray.int(width, 2)

    bytes = sox_get_bytes(file)
    size = bytes.size

    bucket_size = (size.to_f / width).ceil

    @abs_max = bytes.to_a.map(&:abs).max

    size.times do |i|
      value = bytes[i]
      index = i / bucket_size

      # local minimum/maximum
      buckets[index, 0] = value if value < buckets[index, 0]
      buckets[index, 1] = value if value > buckets[index, 1]
    end

    return buckets
  end

  def sox_get_bytes(file)
    sox_command = ['sox', file, '-t', 'raw', '-r', '22050', '-c', '1', '-s', '-L', '-']

    x = nil
    # we have to fork/exec to get a clean commandline
    IO.popen('-') do |f|
      if f.nil?
        $stderr.close
        exec *sox_command
      end
      x = f.read
    end

    raise "sox returned no data, command was\n> #{sox_command.join(' ')}" if x.size == 0

    NArray.to_na(x.unpack("s*"))
  end

  def build_graph(buckets, width, height, color)
    gc = Magick::Draw.new
    midpoint = height / 2
    scale = @abs_max / midpoint

    buckets.shape[0].times do |i|
      scaled_low  = buckets[i, 0] / scale
      scaled_high = buckets[i, 1] / scale

      gc.stroke(color)
      gc.stroke_width(1)
      gc.line(i, midpoint + scaled_low, i, midpoint + scaled_high)
    end

    return gc
  end
end
