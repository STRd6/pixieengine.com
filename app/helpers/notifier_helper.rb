module NotifierHelper
  def project_preview_left(project)
    image = project.image

    return unless image.exists?

    link_to image_tag(image.url(:thumb), :alt => project.display_name, :class => "left", :style => "display:inline-block;float:left;margin-right:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def project_preview_right(project)
    image = project.image

    return unless image.exists?

    link_to image_tag(image.url(:thumb), :alt => project.display_name, :class => "right", :style => "display:inline-block;float:right;margin-left:1em;width:96px;height:96px;"), fullscreen_project_url(project, @link_tracking)
  end

  def image_left(image_name)
    image_tag("#{root_url}assets/newsletters/#{image_name}.png", :alt => image_name, :class => "left", :style => "display:inline-block;float:left;margin-right:1em;")
  end

  def image_right(image_name)
    image_tag("#{root_url}assets/newsletters/#{image_name}.png", :alt => image_name, :class => "right", :style => "display:inline-block;float:right;margin-left:1em;")
  end

  def image_center(image_name)
    "<center>#{image_tag("#{root_url}assets/newsletters/#{image_name}.png", :alt => image_name, :style => "display:block;margin:auto;")}</center>"
  end

  def project_link(project, options=nil)
    ide_url = ide_project_url(project, @link_tracking)

    if options && options[:text]
      ide_url
    else
      link_to project.display_name, ide_url
    end
  end

  def user_link(user, options=nil)
    url = user_url(user, @link_tracking)
    link = link_to(user, url)

    avatar = user.avatar

    if avatar.exists? == false
      "#{link}".html_safe
    elsif (options && options[:text])
      url
    else
      "#{link_to image_tag(avatar.url(:thumb), :alt => user.display_name, :class => :avatar), url} #{link}".html_safe
    end
  end

  def sprites_html(sprites)
    list = sprites.map do |sprite|
      sprite_link(sprite)
    end.each_slice(2).map do |pair|
      pair.join(" ")
    end.join("<br>")
  end

  def sprite_link(sprite)
    url = sprite_url(sprite, @link_tracking)
    link = link_to(sprite.display_name, url)

    "#{link_to image_tag(sprite.image.url, :size => "#{sprite.width}x#{sprite.height}", :alt => sprite.display_name), url} #{link}".html_safe
  end
end
