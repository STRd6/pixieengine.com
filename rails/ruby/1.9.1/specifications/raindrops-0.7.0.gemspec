# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{raindrops}
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["raindrops hackers"]
  s.date = %q{2011-06-27}
  s.description = %q{Raindrops is a real-time stats toolkit to show statistics for Rack HTTP
servers.  It is designed for preforking servers such as Rainbows! and
Unicorn, but should support any Rack HTTP server under Ruby 1.9, 1.8 and
Rubinius on platforms supporting POSIX shared memory.  It may also be
used as a generic scoreboard for sharing atomic counters across multiple
processes.}
  s.email = %q{raindrops@librelist.org}
  s.extensions = ["ext/raindrops/extconf.rb"]
  s.files = ["test/test_aggregate_pmq.rb", "test/test_inet_diag_socket.rb", "test/test_last_data_recv_unicorn.rb", "test/test_linux.rb", "test/test_linux_all_tcp_listen_stats.rb", "test/test_linux_all_tcp_listen_stats_leak.rb", "test/test_linux_ipv6.rb", "test/test_linux_middleware.rb", "test/test_linux_tcp_info.rb", "test/test_middleware.rb", "test/test_middleware_unicorn.rb", "test/test_middleware_unicorn_ipv6.rb", "test/test_raindrops.rb", "test/test_raindrops_gc.rb", "test/test_struct.rb", "test/test_watcher.rb", "ext/raindrops/extconf.rb"]
  s.homepage = %q{http://raindrops.bogomips.org/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rainbows}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{real-time stats for preforking Rack servers}
  s.test_files = ["test/test_aggregate_pmq.rb", "test/test_inet_diag_socket.rb", "test/test_last_data_recv_unicorn.rb", "test/test_linux.rb", "test/test_linux_all_tcp_listen_stats.rb", "test/test_linux_all_tcp_listen_stats_leak.rb", "test/test_linux_ipv6.rb", "test/test_linux_middleware.rb", "test/test_linux_tcp_info.rb", "test/test_middleware.rb", "test/test_middleware_unicorn.rb", "test/test_middleware_unicorn_ipv6.rb", "test/test_raindrops.rb", "test/test_raindrops_gc.rb", "test/test_struct.rb", "test/test_watcher.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0.10"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0.10"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0.10"])
  end
end
