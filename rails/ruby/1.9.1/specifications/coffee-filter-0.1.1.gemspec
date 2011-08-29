# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{coffee-filter}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Nicholson"]
  s.date = %q{2011-05-29}
  s.description = %q{CoffeeFilter is a custom haml filter for rendering coffeescript inside your haml templates. It was inspired by Ivan Nemytchenko's coffee-haml-filter but I wanted an installable gem and coffeescript as the filter name.}
  s.email = ["paul@webpowerdesign.net"]
  s.homepage = %q{http://github.com/paulnicholson/coffee-filter}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{coffee-filter}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{CoffeeFilter is a custom haml filter for rendering coffeescript.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<haml>, [">= 3.0.18"])
      s.add_runtime_dependency(%q<coffee-script>, [">= 2.2.0"])
    else
      s.add_dependency(%q<haml>, [">= 3.0.18"])
      s.add_dependency(%q<coffee-script>, [">= 2.2.0"])
    end
  else
    s.add_dependency(%q<haml>, [">= 3.0.18"])
    s.add_dependency(%q<coffee-script>, [">= 2.2.0"])
  end
end
