class UserPlugin < ActiveRecord::Base
  belongs_to :user
  belongs_to :plugin

  validates_presence_of :user, :plugin
end
