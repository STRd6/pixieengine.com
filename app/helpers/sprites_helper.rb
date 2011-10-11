module SpritesHelper
  def sprite_tag_link(sprite, tag)
    render :partial => "sprites/tag", :object => tag, :locals => {:sprite => sprite}
  end

  def tag_link(tag)
    render :partial => "shared/tag", :object => tag
  end

  def image_url(sprite)
    if sprite
      id = sprite.id

      if sprite.frames > 1
        "/production/images/#{id}.gif"
      else
        "/production/images/#{id}.png"
      end
    else
      nil
    end
  end

  def author_link(sprite)
    user = sprite.user

    "By #{user ? link_to(user, user) : 'Anonymous'}".html_safe
  end

  def image_link(sprite)
    display_name = sprite.display_name

    link_to image_tag(sprite.image.url(:thumb), :alt => display_name, :title => display_name), sprite
  end
end
