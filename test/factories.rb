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
