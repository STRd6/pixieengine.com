Factory.sequence :email do |n|
  "test_#{n}@example.com"
end

Factory.define :user do |user|
  user.email { Factory.next(:email) }
end
