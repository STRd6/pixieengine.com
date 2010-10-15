class AppSprite < ActiveRecord::Base
  belongs_to :app
  belongs_to :sprite
end
