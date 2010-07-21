class Plugin < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, :class_name => "Plugin"

  validates_presence_of :title, :plugin_type, :code
end
