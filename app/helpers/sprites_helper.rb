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
end
