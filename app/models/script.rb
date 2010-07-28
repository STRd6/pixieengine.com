class Script < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, :class_name => "Script"

  validates_presence_of :title, :script_type, :code
end
