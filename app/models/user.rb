class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.require_password_confirmation = false
  end

  has_many :sprites
  has_many :favorites

  after_create do
    Notifier.welcome_email(self).deliver
  end

  def to_s
    display_name
  end

  def remove_favorite(sprite)
    favorites.find_by_sprite_id(sprite.id).destroy
  end

  def display_name
    if super.blank?
      "Anonymous#{id}"
    else
      super
    end
  end
end
