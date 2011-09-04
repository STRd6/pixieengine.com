# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{require}
  s.version = "0.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Winton Welsh"]
  s.date = %q{2010-04-08}
  s.email = %q{mail@wintoni.us}
  s.homepage = %q{http://github.com/winton/require}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Manage your project's dependencies with a pretty DSL}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
