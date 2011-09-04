# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pdf-writer}
  s.version = "1.1.8"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Austin Ziegler"]
  s.autorequire = %q{pdf/writer}
  s.cert_chain = nil
  s.date = %q{2008-03-15}
  s.default_executable = %q{techbook}
  s.description = %q{This library provides the ability to create PDF documents using only native Ruby libraries. There are several demo programs available in the demo/ directory. The canonical documentation for PDF::Writer is "manual.pdf", which can be generated using bin/techbook (just "techbook" for RubyGem users) and the manual file "manual.pwd".}
  s.email = %q{austin@rubyforge.org}
  s.executables = ["techbook"]
  s.files = ["bin/techbook"]
  s.homepage = %q{http://rubyforge.org/projects/ruby-pdf}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubyforge_project = %q{ruby-pdf}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A pure Ruby PDF document creation library.}

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<color>, [">= 1.4.0"])
      s.add_runtime_dependency(%q<transaction-simple>, ["~> 1.3"])
    else
      s.add_dependency(%q<color>, [">= 1.4.0"])
      s.add_dependency(%q<transaction-simple>, ["~> 1.3"])
    end
  else
    s.add_dependency(%q<color>, [">= 1.4.0"])
    s.add_dependency(%q<transaction-simple>, ["~> 1.3"])
  end
end
