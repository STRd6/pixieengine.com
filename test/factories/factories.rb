FactoryGirl.define do
  factory :collection do
    user
    name "TEST"
  end

  factory :collection_item do
    collection
    association :item, :factory => :sprite
  end

  factory :user do
    sequence(:email) do |n|
      "test_#{n}@example.com"
    end
    sequence(:display_name) do |n|
      "teSt-user_#{n}"
    end
    password "TEST1234"
  end

  factory :sprite do
    width 16
    height 16
    title "CommentableSprite"
    user
  end

  factory :link do
    user
    association :target, :factory => :user
  end

  factory :plugin do
    user
    code "{}"
    title "Test"
    plugin_type "tool"
  end

  factory :project do
    user
    title "TESTING"
  end

  factory :comment do
    association :commenter, :factory => :user
    association :commentee, :factory => :user
    body "This is a test comment"
    association :commentable, :factory => :sprite
  end

  factory :membership do
    user
    association :group, :factory => :project
  end
end
