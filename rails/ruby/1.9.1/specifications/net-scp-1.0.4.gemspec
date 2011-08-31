# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{net-scp}
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck", "Delano Mandelbaum"]
  s.date = %q{2010-08-16}
  s.description = %q{A pure Ruby implementation of the SCP client protocol}
  s.email = %q{net-scp@solutious.com}
  s.files = ["test/test_all.rb"]
  s.homepage = %q{http://net-ssh.rubyforge.org/scp}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{net-ssh}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A pure Ruby implementation of the SCP client protocol}
  s.test_files = ["test/test_all.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<net-ssh>, [">= 1.99.1"])
    else
      s.add_dependency(%q<net-ssh>, [">= 1.99.1"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 1.99.1"])
  end
end
