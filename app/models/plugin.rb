class Plugin < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :title, :plugin_type, :code
end
