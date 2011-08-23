module SpritesHelper
  def sprite_tag_link(sprite, tag)
    render :partial => "sprites/tag", :object => tag, :locals => {:sprite => sprite}
  end

  def tag_link(tag)
    render :partial => "shared/tag", :object => tag
  end

  def image_url(sprite)
    if sprite
      if sprite.frames > 1
        "/production/images/#{sprite.id}.gif"
      else
        "/production/images/#{sprite.id}.png"
      end
    else
      nil
    end
  end

  def author_link(sprite)
    "By #{sprite.user ? link_to(sprite.user, sprite.user) : 'Anonymous'}".html_safe
  end

  def image_link(sprite)
    link_to image_tag(sprite.image.url(:thumb), :alt => sprite.display_name, :title => sprite.display_name), sprite
  end
end
