# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{simple_form}
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["José Valim", "Carlos Antônio"]
  s.date = %q{2011-06-26}
  s.description = %q{Forms made easy!}
  s.email = %q{contact@plataformatec.com.br}
  s.files = ["test/action_view_extensions/builder_test.rb", "test/action_view_extensions/form_helper_test.rb", "test/components/error_test.rb", "test/components/hint_test.rb", "test/components/label_test.rb", "test/components/wrapper_test.rb", "test/discovery_inputs.rb", "test/error_notification_test.rb", "test/form_builder_test.rb", "test/inputs_test.rb", "test/simple_form_test.rb", "test/support/misc_helpers.rb", "test/support/mock_controller.rb", "test/support/mock_response.rb", "test/support/models.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/plataformatec/simple_form}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{simple_form}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Forms made easy!}
  s.test_files = ["test/action_view_extensions/builder_test.rb", "test/action_view_extensions/form_helper_test.rb", "test/components/error_test.rb", "test/components/hint_test.rb", "test/components/label_test.rb", "test/components/wrapper_test.rb", "test/discovery_inputs.rb", "test/error_notification_test.rb", "test/form_builder_test.rb", "test/inputs_test.rb", "test/simple_form_test.rb", "test/support/misc_helpers.rb", "test/support/mock_controller.rb", "test/support/mock_response.rb", "test/support/models.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_runtime_dependency(%q<actionpack>, ["~> 3.0"])
    else
      s.add_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_dependency(%q<actionpack>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<activemodel>, ["~> 3.0"])
    s.add_dependency(%q<actionpack>, ["~> 3.0"])
  end
end
