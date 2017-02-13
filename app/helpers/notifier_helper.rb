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

  def cta_style
    "text-decoration: none; border-radius: 4px; padding: 16px 16px 16px 16px; font-size: 16px; line-height: 16px; color: white; background-color: #03a9f4;"
  end

  def unsubscribe_url_for(email)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets.secret_key_base)
    signature = verifier.generate(email)

    unsubscribe_url(signature: signature)
  end
end
