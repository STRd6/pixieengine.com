module NotifierHelper
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

    "#{link_to image_tag(sprite.image_url, :size => "#{sprite.width}x#{sprite.height}", :alt => sprite.display_name), url} #{link}".html_safe
  end
end
