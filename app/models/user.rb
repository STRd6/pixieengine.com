class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_email_field = false
    config.validate_password_field = false
    config.require_password_confirmation = false
  end

  include ExampleProfile

  has_many :sprites
  has_many :favorites

  after_create do
    Notifier.welcome_email(self).deliver unless email.blank?
  end

  def to_s
    display_name
  end

  def remove_favorite(sprite)
    favorites.find_by_sprite_id(sprite.id).destroy
  end

  def favorite?(sprite)
    favorites.find_by_sprite_id sprite.id
  end

  def broadcast(message)
    if twitter = authenticated_with?(:twitter)
      twitter.post("/statuses/update.json",
        "status" => message
      )
    end
  end

  def display_name
    if super.blank?
      "Anonymous#{id}"
    else
      super
    end
  end
end
