# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{coffee-script-source}
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Ashkenas"]
  s.date = %q{2011-08-04}
  s.description = %q{      CoffeeScript is a little language that compiles into JavaScript.
 \     Underneath all of those embarrassing braces and semicolons,
      JavaScript has always had a gorgeous object model at its heart.
      CoffeeScript is an attempt to expose the good parts of JavaScript
      in a simple way.
}
  s.email = %q{jashkenas@gmail.com}
  s.homepage = %q{http://jashkenas.github.com/coffee-script/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{coffee-script-source}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{The CoffeeScript Compiler}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
