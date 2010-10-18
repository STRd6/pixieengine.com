class Script < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, :class_name => "Script"

  has_many :script_members
  has_many :members, :through => :script_members, :source => :user

  validates_presence_of :title, :script_type, :code

  def has_access?(user)
    members.exists? user
  end
end
