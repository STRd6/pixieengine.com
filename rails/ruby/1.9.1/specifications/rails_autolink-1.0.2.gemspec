# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails_autolink}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson", "Juanjo Bazan", "Akira Matsuda"]
  s.date = %q{2011-06-17}
  s.description = %q{This is an extraction of the `auto_link` method from rails.  The `auto_link`
method was removed from Rails in version Rails 3.1.  This gem is meant to
bridge the gap for people migrating.}
  s.email = ["aaron@tenderlovemaking.com", "jjbazan@gmail.com", "ronnie@dio.jp"]
  s.files = ["test/test_rails_autolink.rb"]
  s.homepage = %q{http://github.com/tenderlove/rails_autolink}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rails_autolink}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{This is an extraction of the `auto_link` method from rails}
  s.test_files = ["test/test_rails_autolink.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.1.0.a"])
      s.add_development_dependency(%q<minitest>, [">= 1.6.0"])
      s.add_development_dependency(%q<hoe>, [">= 2.9.4"])
    else
      s.add_dependency(%q<rails>, ["~> 3.1.0.a"])
      s.add_dependency(%q<minitest>, [">= 1.6.0"])
      s.add_dependency(%q<hoe>, [">= 2.9.4"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.1.0.a"])
    s.add_dependency(%q<minitest>, [">= 1.6.0"])
    s.add_dependency(%q<hoe>, [">= 2.9.4"])
  end
end
