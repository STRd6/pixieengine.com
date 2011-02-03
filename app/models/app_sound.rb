class AppSound < ActiveRecord::Base
  belongs_to :app
  belongs_to :sprite

  delegate :data_url, :to => :sound
  delegate :user, :has_access?, :to => :app
end
