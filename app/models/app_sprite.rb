class AppSprite < ActiveRecord::Base
  belongs_to :app
  belongs_to :sprite

  delegate :data_url, :width, :height, :to => :sprite
  delegate :user, :to => :app
end
