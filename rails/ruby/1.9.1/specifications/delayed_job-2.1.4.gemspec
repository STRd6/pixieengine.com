# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{delayed_job}
  s.version = "2.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Gaffney", "Brandon Keepers", "Tobias Lütke"]
  s.date = %q{2011-02-10}
  s.description = %q{Delayed_job (or DJ) encapsulates the common pattern of asynchronously executing longer tasks in the background. It is a direct extraction from Shopify where the job table is responsible for a multitude of core tasks.

This gem is collectiveidea's fork (http://github.com/collectiveidea/delayed_job).}
  s.email = ["chris@collectiveidea.com", "brandon@opensoul.org"]
  s.files = ["spec/active_record_job_spec.rb", "spec/autoloaded/clazz.rb", "spec/autoloaded/struct.rb", "spec/database.yml", "spec/message_sending_spec.rb", "spec/performable_mailer_spec.rb", "spec/performable_method_spec.rb", "spec/sample_jobs.rb", "spec/spec_helper.rb", "spec/worker_spec.rb", "spec/yaml_ext_spec.rb"]
  s.homepage = %q{http://github.com/collectiveidea/delayed_job}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Database-backed asynchronous priority queue system -- Extracted from Shopify}
  s.test_files = ["spec/active_record_job_spec.rb", "spec/autoloaded/clazz.rb", "spec/autoloaded/struct.rb", "spec/database.yml", "spec/message_sending_spec.rb", "spec/performable_mailer_spec.rb", "spec/performable_method_spec.rb", "spec/sample_jobs.rb", "spec/spec_helper.rb", "spec/worker_spec.rb", "spec/yaml_ext_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<daemons>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0"])
      s.add_development_dependency(%q<rails>, ["~> 3.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<mysql>, [">= 0"])
    else
      s.add_dependency(%q<daemons>, [">= 0"])
      s.add_dependency(%q<activesupport>, ["~> 3.0"])
      s.add_dependency(%q<rails>, ["~> 3.0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<mysql>, [">= 0"])
    end
  else
    s.add_dependency(%q<daemons>, [">= 0"])
    s.add_dependency(%q<activesupport>, ["~> 3.0"])
    s.add_dependency(%q<rails>, ["~> 3.0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<mysql>, [">= 0"])
  end
end
