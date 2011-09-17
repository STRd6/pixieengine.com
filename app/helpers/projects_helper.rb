module ProjectsHelper
  def user_link(user)
    "#{link_to image_tag(user.avatar.url(:thumb), :alt => user.display_name, :class => :avatar), user} #{link_to user, user}".html_safe
  end
end
