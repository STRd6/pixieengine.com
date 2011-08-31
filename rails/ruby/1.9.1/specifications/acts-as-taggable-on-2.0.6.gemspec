# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts-as-taggable-on}
  s.version = "2.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2010-05-18}
  s.description = %q{With ActsAsTaggableOn, you could tag a single model on several contexts, such as skills, interests, and awards. It also provides other advanced functionality.}
  s.email = %q{michael@intridea.com}
  s.files = ["spec/acts_as_taggable_on/acts_as_taggable_on_spec.rb", "spec/acts_as_taggable_on/acts_as_tagger_spec.rb", "spec/acts_as_taggable_on/tag_list_spec.rb", "spec/acts_as_taggable_on/tag_spec.rb", "spec/acts_as_taggable_on/taggable_spec.rb", "spec/acts_as_taggable_on/tagger_spec.rb", "spec/acts_as_taggable_on/tagging_spec.rb", "spec/acts_as_taggable_on/tags_helper_spec.rb", "spec/bm.rb", "spec/models.rb", "spec/schema.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/mbleigh/acts-as-taggable-on}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{ActsAsTaggableOn is a tagging plugin for Rails that provides multiple tagging contexts on a single model.}
  s.test_files = ["spec/acts_as_taggable_on/acts_as_taggable_on_spec.rb", "spec/acts_as_taggable_on/acts_as_tagger_spec.rb", "spec/acts_as_taggable_on/tag_list_spec.rb", "spec/acts_as_taggable_on/tag_spec.rb", "spec/acts_as_taggable_on/taggable_spec.rb", "spec/acts_as_taggable_on/tagger_spec.rb", "spec/acts_as_taggable_on/tagging_spec.rb", "spec/acts_as_taggable_on/tags_helper_spec.rb", "spec/bm.rb", "spec/models.rb", "spec/schema.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
