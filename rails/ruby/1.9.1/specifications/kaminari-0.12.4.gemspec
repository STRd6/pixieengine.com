# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kaminari}
  s.version = "0.12.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Akira Matsuda"]
  s.date = %q{2011-05-04}
  s.description = %q{Kaminari is a Scope & Engine based, clean, powerful, customizable and sophisticated paginator for Rails 3}
  s.email = ["ronnie@dio.jp"]
  s.files = ["spec/acceptance/acceptance_helper.rb", "spec/acceptance/support/helpers.rb", "spec/acceptance/support/paths.rb", "spec/acceptance/users_spec.rb", "spec/config/config_spec.rb", "spec/fake_app.rb", "spec/helpers/action_view_extension_spec.rb", "spec/helpers/helpers_spec.rb", "spec/helpers/tags_spec.rb", "spec/models/active_record_relation_methods_spec.rb", "spec/models/array_spec.rb", "spec/models/default_per_page_spec.rb", "spec/models/mongo_mapper_spec.rb", "spec/models/mongoid_spec.rb", "spec/models/scopes_spec.rb", "spec/spec_helper.rb", "spec/support/database_cleaner.rb", "spec/support/matchers.rb"]
  s.homepage = %q{https://github.com/amatsuda/kaminari}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{kaminari}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A pagination engine plugin for Rails 3}
  s.test_files = ["spec/acceptance/acceptance_helper.rb", "spec/acceptance/support/helpers.rb", "spec/acceptance/support/paths.rb", "spec/acceptance/users_spec.rb", "spec/config/config_spec.rb", "spec/fake_app.rb", "spec/helpers/action_view_extension_spec.rb", "spec/helpers/helpers_spec.rb", "spec/helpers/tags_spec.rb", "spec/models/active_record_relation_methods_spec.rb", "spec/models/array_spec.rb", "spec/models/default_per_page_spec.rb", "spec/models/mongo_mapper_spec.rb", "spec/models/mongoid_spec.rb", "spec/models/scopes_spec.rb", "spec/spec_helper.rb", "spec/support/database_cleaner.rb", "spec/support/matchers.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.0.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<mongoid>, [">= 2"])
      s.add_development_dependency(%q<mongo_mapper>, [">= 0.9"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 0"])
      s.add_development_dependency(%q<rr>, [">= 0"])
      s.add_development_dependency(%q<steak>, [">= 0"])
      s.add_development_dependency(%q<capybara>, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 3.0.0"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<mongoid>, [">= 2"])
      s.add_dependency(%q<mongo_mapper>, [">= 0.9"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, [">= 0"])
      s.add_dependency(%q<rr>, [">= 0"])
      s.add_dependency(%q<steak>, [">= 0"])
      s.add_dependency(%q<capybara>, [">= 0"])
      s.add_dependency(%q<database_cleaner>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.0.0"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<mongoid>, [">= 2"])
    s.add_dependency(%q<mongo_mapper>, [">= 0.9"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, [">= 0"])
    s.add_dependency(%q<rr>, [">= 0"])
    s.add_dependency(%q<steak>, [">= 0"])
    s.add_dependency(%q<capybara>, [">= 0"])
    s.add_dependency(%q<database_cleaner>, [">= 0"])
  end
end
