# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{activemodel}
  s.version = "3.1.0.rc8"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson"]
  s.date = %q{2011-08-28}
  s.description = %q{A toolkit for building modeling frameworks like Active Record and Active Resource. Rich support for attributes, callbacks, validations, observers, serialization, internationalization, and testing.}
  s.email = %q{david@loudthinking.com}
  s.homepage = %q{http://www.rubyonrails.org}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A toolkit for building modeling frameworks (part of Rails).}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["= 3.1.0.rc8"])
      s.add_runtime_dependency(%q<builder>, ["~> 3.0.0"])
      s.add_runtime_dependency(%q<i18n>, ["~> 0.6"])
      s.add_runtime_dependency(%q<bcrypt-ruby>, ["~> 3.0.0"])
    else
      s.add_dependency(%q<activesupport>, ["= 3.1.0.rc8"])
      s.add_dependency(%q<builder>, ["~> 3.0.0"])
      s.add_dependency(%q<i18n>, ["~> 0.6"])
      s.add_dependency(%q<bcrypt-ruby>, ["~> 3.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["= 3.1.0.rc8"])
    s.add_dependency(%q<builder>, ["~> 3.0.0"])
    s.add_dependency(%q<i18n>, ["~> 0.6"])
    s.add_dependency(%q<bcrypt-ruby>, ["~> 3.0.0"])
  end
end
