# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sass}
  s.version = "3.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Weizenbaum", "Chris Eppstein", "Hampton Catlin"]
  s.date = %q{2011-08-04}
  s.description = %q{      Sass makes CSS fun again. Sass is an extension of CSS3, adding
      nested rules, variables, mixins, selector inheritance, and more.
      It's translated to well-formatted, standard CSS using the
      command line tool or a web-framework plugin.
}
  s.email = %q{sass-lang@googlegroups.com}
  s.executables = ["sass", "sass-convert"]
  s.files = ["test/sass/engine_test.rb", "test/sass/functions_test.rb", "test/sass/extend_test.rb", "test/sass/logger_test.rb", "test/sass/css2sass_test.rb", "test/sass/conversion_test.rb", "test/sass/script_test.rb", "test/sass/util/subset_map_test.rb", "test/sass/callbacks_test.rb", "test/sass/importer_test.rb", "test/sass/scss/css_test.rb", "test/sass/scss/scss_test.rb", "test/sass/scss/rx_test.rb", "test/sass/util_test.rb", "test/sass/script_conversion_test.rb", "test/sass/less_conversion_test.rb", "test/sass/cache_test.rb", "test/sass/plugin_test.rb", "bin/sass", "bin/sass-convert"]
  s.homepage = %q{http://sass-lang.com/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sass}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A powerful but elegant CSS compiler that makes CSS fun again.}
  s.test_files = ["test/sass/engine_test.rb", "test/sass/functions_test.rb", "test/sass/extend_test.rb", "test/sass/logger_test.rb", "test/sass/css2sass_test.rb", "test/sass/conversion_test.rb", "test/sass/script_test.rb", "test/sass/util/subset_map_test.rb", "test/sass/callbacks_test.rb", "test/sass/importer_test.rb", "test/sass/scss/css_test.rb", "test/sass/scss/scss_test.rb", "test/sass/scss/rx_test.rb", "test/sass/util_test.rb", "test/sass/script_conversion_test.rb", "test/sass/less_conversion_test.rb", "test/sass/cache_test.rb", "test/sass/plugin_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<yard>, [">= 0.5.3"])
      s.add_development_dependency(%q<maruku>, [">= 0.5.9"])
    else
      s.add_dependency(%q<yard>, [">= 0.5.3"])
      s.add_dependency(%q<maruku>, [">= 0.5.9"])
    end
  else
    s.add_dependency(%q<yard>, [">= 0.5.3"])
    s.add_dependency(%q<maruku>, [">= 0.5.9"])
  end
end
