# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aaronh-chronic}
  s.version = "0.3.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Preston-Werner"]
  s.autorequire = %q{chronic}
  s.date = %q{2010-09-10}
  s.email = %q{tom@rubyisawesome.com}
  s.files = ["test/suite.rb"]
  s.homepage = %q{http://chronic.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A natural language date parser with timezone support}
  s.test_files = ["test/suite.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
