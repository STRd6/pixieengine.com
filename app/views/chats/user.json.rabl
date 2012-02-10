object @user

attributes :display_name, :id

node(:avatar) { |user| user.avatar.url(:thumb) }

node(:color) do |user|
  (user.favorite_color || "000").sub('#', '').sub('FFFFFF', '000')
end

node(:user_path) { |user| user_path(user) }
