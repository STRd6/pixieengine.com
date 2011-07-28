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
  user.password "TEST123"
end

Factory.define :sprite do |sprite|
  sprite.width 16
  sprite.height 16
  sprite.title "CommentableSprite"
  sprite.user {Factory :user}
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
  sound.wav File.new(File.join(Rails.root, "/test/test.wav"))
  sound.sfs File.new(File.join(Rails.root, "/test/test.sfs"))
end

Factory.define :project do |project|
  project.user {Factory :user}
  project.title "TESTING"
  project.description "this is a test project"
end

Factory.define :comment do |comment|
  comment.commenter {Factory :user}
  comment.commentee {Factory :user}
  comment.body "This is a test comment"
  comment.commentable {Factory :sprite}
end
