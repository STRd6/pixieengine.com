Factory.define :app do |app|
  app.title "TEST"
  app.user {Factory :user}
end

Factory.define :collection do |collection|
  collection.user {Factory :user}
  collection.name "TEST"
end

Factory.define :collection_item do |collection_item|
  collection_item.collection {Factory :collection}
  collection_item.item {Factory :sprite}
end

Factory.sequence :email do |n|
  "test_#{n}@example.com"
end

Factory.define :library do |library|
  library.title "TEST"
  library.user { Factory(:user) }
end

Factory.define :user do |user|
  user.email { Factory.next(:email) }
  user.password "TEST"
end

Factory.define :script do |script|
  script.title "TEST"
  script.script_type "test"
  script.code "alert('test');"
end

Factory.define :sprite do |sprite|
  sprite.width 16
  sprite.height 16
end

Factory.define :link do |link|
  link.user {Factory :user}
  link.target {Factory :user}
end

Factory.define :plugin do |plugin|
  plugin.user {Factory :user}
  plugin.code "{}"
  plugin.title "Test"
  plugin.plugin_type "tool"
end

Factory.define :sound do |sound|
  sound.wav File.new("#{RAILS_ROOT}/test/test.wav")
  sound.sfs File.new("#{RAILS_ROOT}/test/test.sfs")
end

Factory.define :project do |project|
  project.user {Factory :user}
  project.title "TESTING"
  project.description "this is a test project"
end
