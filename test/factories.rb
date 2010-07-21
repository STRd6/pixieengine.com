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

Factory.define :user do |user|
  user.email { Factory.next(:email) }
  user.password "TEST"
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
