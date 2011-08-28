module NotifierHelper
  def project_preview_link(project)
    link_to image_tag(project.image.url(:thumb), :alt => project.display_name, :style => "display:inline-block;margin-left:1em;margin-right:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def project_preview_left(project)
    link_to image_tag(project.image.url(:thumb), :alt => project.display_name, :style => "display:inline-block;float:left;margin-right:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def project_preview_right(project)
    link_to image_tag(project.image.url(:thumb), :alt => project.display_name, :style => "display:inline-block;float:right;margin-left:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def project_ide_link(project)
    link_to(project.display_name, ide_project_url(project, @link_tracking))
  end

  def user_link(user)
    link_to user.display_name, user_url(user, @link_tracking)
  end
end

