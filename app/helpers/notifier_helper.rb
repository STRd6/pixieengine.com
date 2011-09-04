module NotifierHelper
  def project_preview_left(project)
    link_to image_tag(project.image.url(:thumb), :alt => project.display_name, :style => "display:inline-block;float:left;margin-right:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def project_preview_right(project)
    link_to image_tag(project.image.url(:thumb), :alt => project.display_name, :style => "display:inline-block;float:right;margin-left:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def user_link(user)
    "#{link_to image_tag(user.avatar.url(:thumb), :alt => user.display_name, :class => :avatar), user_url(user, @link_tracking)} #{link_to user, user_url(user, @link_tracking)}".html_safe
  end
end

