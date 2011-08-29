# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{net-ssh}
  s.version = "2.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck", "Delano Mandelbaum"]
  s.date = %q{2011-08-16}
  s.description = %q{Net::SSH: a pure-Ruby implementation of the SSH2 client protocol.}
  s.email = ["net-ssh@solutious.com"]
  s.homepage = %q{http://github.com/net-ssh/net-ssh}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{net-ssh}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Net::SSH: a pure-Ruby implementation of the SSH2 client protocol.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
