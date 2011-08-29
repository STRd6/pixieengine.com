# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{net-sftp}
  s.version = "2.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck"]
  s.date = %q{2010-08-18}
  s.description = %q{A pure Ruby implementation of the SFTP client protocol}
  s.email = %q{netsftp@solutious.com}
  s.files = ["test/test_all.rb"]
  s.homepage = %q{http://net-ssh.rubyforge.org/sftp}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{net-ssh}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A pure Ruby implementation of the SFTP client protocol}
  s.test_files = ["test/test_all.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.9"])
    else
      s.add_dependency(%q<net-ssh>, [">= 2.0.9"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 2.0.9"])
  end
end
