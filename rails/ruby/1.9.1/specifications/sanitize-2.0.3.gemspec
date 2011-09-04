# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sanitize}
  s.version = "2.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Grove"]
  s.date = %q{2011-07-02}
  s.email = %q{ryan@wonko.com}
  s.homepage = %q{https://github.com/rgrove/sanitize/}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{riposte}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Whitelist-based HTML sanitizer.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["< 1.6", ">= 1.4.4"])
      s.add_development_dependency(%q<minitest>, ["~> 2.0.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.0"])
    else
      s.add_dependency(%q<nokogiri>, ["< 1.6", ">= 1.4.4"])
      s.add_dependency(%q<minitest>, ["~> 2.0.0"])
      s.add_dependency(%q<rake>, ["~> 0.8.0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["< 1.6", ">= 1.4.4"])
    s.add_dependency(%q<minitest>, ["~> 2.0.0"])
    s.add_dependency(%q<rake>, ["~> 0.8.0"])
  end
end
