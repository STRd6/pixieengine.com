# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{chunky_png}
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Willem van Bergen"]
  s.date = %q{2011-08-09}
  s.description = %q{    This pure Ruby library can read and write PNG images without depending on an external 
    image library, like RMagick. It tries to be memory efficient and reasonably fast.
    
    It supports reading and writing all PNG variants that are defined in the specification, 
    with one limitation: only 8-bit color depth is supported. It supports all transparency, 
    interlacing and filtering options the PNG specifications allows. It can also read and 
    write textual metadata from PNG files. Low-level read/write access to PNG chunks is
    also possible.
    
    This library supports simple drawing on the image canvas and simple operations like
    alpha composition and cropping. Finally, it can import from and export to RMagick for 
    interoperability.
    
    Also, have a look at OilyPNG at http://github.com/wvanbergen/oily_png. OilyPNG is a 
    drop in mixin module that implements some of the ChunkyPNG algorithms in C, which 
    provides a massive speed boost to encoding and decoding.
}
  s.email = ["willem@railsdoctors.com"]
  s.files = ["spec/chunky_png/canvas/adam7_interlacing_spec.rb", "spec/chunky_png/canvas/drawing_spec.rb", "spec/chunky_png/canvas/masking_spec.rb", "spec/chunky_png/canvas/operations_spec.rb", "spec/chunky_png/canvas/png_decoding_spec.rb", "spec/chunky_png/canvas/png_encoding_spec.rb", "spec/chunky_png/canvas/resampling_spec.rb", "spec/chunky_png/canvas/stream_exporting_spec.rb", "spec/chunky_png/canvas/stream_importing_spec.rb", "spec/chunky_png/canvas_spec.rb", "spec/chunky_png/color_spec.rb", "spec/chunky_png/datastream_spec.rb", "spec/chunky_png/dimension_spec.rb", "spec/chunky_png/image_spec.rb", "spec/chunky_png/point_spec.rb", "spec/chunky_png/rmagick_spec.rb", "spec/chunky_png/vector_spec.rb", "spec/chunky_png_spec.rb", "spec/png_suite_spec.rb"]
  s.homepage = %q{http://wiki.github.com/wvanbergen/chunky_png}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Pure ruby library for read/write, chunk-level access to PNG files}
  s.test_files = ["spec/chunky_png/canvas/adam7_interlacing_spec.rb", "spec/chunky_png/canvas/drawing_spec.rb", "spec/chunky_png/canvas/masking_spec.rb", "spec/chunky_png/canvas/operations_spec.rb", "spec/chunky_png/canvas/png_decoding_spec.rb", "spec/chunky_png/canvas/png_encoding_spec.rb", "spec/chunky_png/canvas/resampling_spec.rb", "spec/chunky_png/canvas/stream_exporting_spec.rb", "spec/chunky_png/canvas/stream_importing_spec.rb", "spec/chunky_png/canvas_spec.rb", "spec/chunky_png/color_spec.rb", "spec/chunky_png/datastream_spec.rb", "spec/chunky_png/dimension_spec.rb", "spec/chunky_png/image_spec.rb", "spec/chunky_png/point_spec.rb", "spec/chunky_png/rmagick_spec.rb", "spec/chunky_png/vector_spec.rb", "spec/chunky_png_spec.rb", "spec/png_suite_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.2"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.2"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.2"])
  end
end
