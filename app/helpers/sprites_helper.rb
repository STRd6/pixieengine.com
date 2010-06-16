module SpritesHelper
  def image_url(sprite)
    if sprite
      "/production/images/#{sprite.id}.png"
    else
      nil
    end
  end
end
