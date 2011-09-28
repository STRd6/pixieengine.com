module NotifierHelper
  def project_preview_left(project)
    link_to image_tag(project.image.url(:thumb), :alt => project.display_name, :class => "left", :style => "display:inline-block;float:left;margin-right:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def project_preview_right(project)
    link_to image_tag(project.image.url(:thumb), :alt => project.display_name, :class => "right", :style => "display:inline-block;float:right;margin-left:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def image_left(image_name)
    image_tag("#{root_url}assets/newsletters/#{image_name}.png", :alt => image_name, :class => "left", :style => "display:inline-block;float:left;margin-right:1em;")
  end

  def image_center(image_name)
    "<center>#{image_tag("#{root_url}assets/newsletters/#{image_name}.png", :alt => image_name, :style => "display:block;margin:auto;")}</center>"
  end

  def project_link(project, options=nil)
    if options && options[:text]
      ide_project_url(project, @link_tracking)
    else
      link_to project.display_name, ide_project_url(project, @link_tracking)
    end
  end

  def user_link(user, options=nil)
    if options && options[:text]
      user_url(user, @link_tracking)
    else
      "#{link_to image_tag(user.avatar.url(:thumb), :alt => user.display_name, :class => :avatar), user_url(user, @link_tracking)} #{link_to user, user_url(user, @link_tracking)}".html_safe
    end
  end
end

