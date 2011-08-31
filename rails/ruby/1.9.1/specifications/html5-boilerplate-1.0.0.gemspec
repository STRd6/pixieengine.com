# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{html5-boilerplate}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Gumeson"]
  s.date = %q{2011-05-11}
  s.description = %q{A Compass extension based on Paul Irish's HTML5 Boilerplate at http://html5boilerplate.com}
  s.email = %q{gumeson@gmail.com}
  s.homepage = %q{http://github.com/sporkd/compass-html5-boilerplate}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A Compass extension based on Paul Irish's HTML5 Boilerplate}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<compass>, [">= 0.11.1"])
    else
      s.add_dependency(%q<compass>, [">= 0.11.1"])
    end
  else
    s.add_dependency(%q<compass>, [">= 0.11.1"])
  end
end
