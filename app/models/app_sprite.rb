class AppSprite < ActiveRecord::Base
  belongs_to :app
  belongs_to :sprite

  def data_url
    sprite.data_url
  end

  def title
    sprite.title
  end

  def user
    app.user
  end
end
