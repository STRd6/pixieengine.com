# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{turn}
  s.version = "0.8.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = %q{2011-03-30}
  s.default_executable = %q{turn}
  s.description = %q{TURN is a new way to view Test::Unit results. With longer running tests, it
can be very frustrating to see a failure (....F...) and then have to wait till
all the tests finish before you can see what the exact failure was. TURN
displays each test on a separate line with failures being displayed
immediately instead of at the end of the tests.

If you have the 'ansi' gem installed, then TURN output will be displayed in
wonderful technicolor (but only if your terminal supports ANSI color codes).
Well, the only colors are green and red, but that is still color.}
  s.email = %q{tim.pease@gmail.com}
  s.executables = ["turn"]
  s.files = ["test/test_framework.rb", "test/test_reporters.rb", "test/test_runners.rb", "bin/turn"]
  s.homepage = %q{http://gemcutter.org/gems/turn}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{turn}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Test::Unit Reporter (New) -- new output format for Test::Unit}
  s.test_files = ["test/test_framework.rb", "test/test_reporters.rb", "test/test_runners.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ansi>, [">= 1.2.2"])
      s.add_development_dependency(%q<bones-git>, [">= 1.2.4"])
      s.add_development_dependency(%q<bones>, [">= 3.6.5"])
    else
      s.add_dependency(%q<ansi>, [">= 1.2.2"])
      s.add_dependency(%q<bones-git>, [">= 1.2.4"])
      s.add_dependency(%q<bones>, [">= 3.6.5"])
    end
  else
    s.add_dependency(%q<ansi>, [">= 1.2.2"])
    s.add_dependency(%q<bones-git>, [">= 1.2.4"])
    s.add_dependency(%q<bones>, [">= 3.6.5"])
  end
end
