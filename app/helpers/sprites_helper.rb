module SpritesHelper
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
