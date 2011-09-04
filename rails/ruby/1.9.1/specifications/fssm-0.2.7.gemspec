# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fssm}
  s.version = "0.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Travis Tilley", "Nathan Weizenbaum", "Chris Eppstein", "Jonathan Castello", "Tuomas Kareinen"]
  s.date = %q{2011-04-20}
  s.description = %q{The File System State Monitor keeps track of the state of any number of paths and will fire events when said state changes (create/update/delete). FSSM supports using FSEvents on MacOS, Inotify on GNU/Linux, and polling anywhere else.}
  s.email = ["ttilley@gmail.com"]
  s.files = ["spec/count_down_latch.rb", "spec/monitor_spec.rb", "spec/path_spec.rb", "spec/root/duck/quack.txt", "spec/root/file.css", "spec/root/file.rb", "spec/root/file.yml", "spec/root/moo/cow.txt", "spec/spec_helper.rb"]
  s.homepage = %q{https://github.com/ttilley/fssm}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{fssm}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{File System State Monitor}
  s.test_files = ["spec/count_down_latch.rb", "spec/monitor_spec.rb", "spec/path_spec.rb", "spec/root/duck/quack.txt", "spec/root/file.css", "spec/root/file.rb", "spec/root/file.yml", "spec/root/moo/cow.txt", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 2.4.0"])
    else
      s.add_dependency(%q<rspec>, [">= 2.4.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.4.0"])
  end
end
