# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hpricot}
  s.version = "0.8.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["why the lucky stiff"]
  s.date = %q{2011-02-27}
  s.description = %q{a swift, liberal HTML parser with a fantastic library}
  s.email = %q{why@ruby-lang.org}
  s.extensions = ["ext/fast_xs/extconf.rb", "ext/hpricot_scan/extconf.rb"]
  s.files = ["ext/fast_xs/extconf.rb", "ext/hpricot_scan/extconf.rb"]
  s.homepage = %q{http://code.whytheluckystiff.net/hpricot/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{hobix}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{a swift, liberal HTML parser with a fantastic library}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
