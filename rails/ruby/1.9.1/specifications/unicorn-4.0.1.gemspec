# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{unicorn}
  s.version = "4.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Unicorn hackers"]
  s.date = %q{2011-06-29}
  s.description = %q{\Unicorn is an HTTP server for Rack applications designed to only serve
fast clients on low-latency, high-bandwidth connections and take
advantage of features in Unix/Unix-like kernels.  Slow clients should
only be served by placing a reverse proxy capable of fully buffering
both the the request and response in between \Unicorn and slow clients.}
  s.email = %q{mongrel-unicorn@rubyforge.org}
  s.executables = ["unicorn", "unicorn_rails"]
  s.extensions = ["ext/unicorn_http/extconf.rb"]
  s.files = ["test/unit/test_configurator.rb", "test/unit/test_http_parser.rb", "test/unit/test_http_parser_ng.rb", "test/unit/test_http_parser_xftrust.rb", "test/unit/test_request.rb", "test/unit/test_response.rb", "test/unit/test_server.rb", "test/unit/test_util.rb", "bin/unicorn", "bin/unicorn_rails", "ext/unicorn_http/extconf.rb"]
  s.homepage = %q{http://unicorn.bogomips.org/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mongrel}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Rack HTTP server for fast clients and Unix}
  s.test_files = ["test/unit/test_configurator.rb", "test/unit/test_http_parser.rb", "test/unit/test_http_parser_ng.rb", "test/unit/test_http_parser_xftrust.rb", "test/unit/test_request.rb", "test/unit/test_response.rb", "test/unit/test_server.rb", "test/unit/test_util.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<kgio>, ["~> 2.4"])
      s.add_runtime_dependency(%q<raindrops>, ["~> 0.6"])
      s.add_development_dependency(%q<isolate>, ["~> 3.1"])
      s.add_development_dependency(%q<wrongdoc>, ["~> 1.5"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<kgio>, ["~> 2.4"])
      s.add_dependency(%q<raindrops>, ["~> 0.6"])
      s.add_dependency(%q<isolate>, ["~> 3.1"])
      s.add_dependency(%q<wrongdoc>, ["~> 1.5"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<kgio>, ["~> 2.4"])
    s.add_dependency(%q<raindrops>, ["~> 0.6"])
    s.add_dependency(%q<isolate>, ["~> 3.1"])
    s.add_dependency(%q<wrongdoc>, ["~> 1.5"])
  end
end
