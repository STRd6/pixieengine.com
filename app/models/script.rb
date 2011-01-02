class Script < ActiveRecord::Base
  versioned

  belongs_to :user
  belongs_to :parent, :class_name => "Script"

  has_many :script_members
  has_many :members, :through => :script_members, :source => :user

  validates_presence_of :title, :script_type, :code

  attr_accessor :lib_id

  after_create :associate_lib

  def has_access?(user)
    members.exists? user
  end

  def associate_lib
    if lib_id
      LibraryScript.create(:library_id => lib_id, :script_id => id)
    end
  end
end
