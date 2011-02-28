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

  def file_name
    name = "#{title.underscore.gsub(" ", '_').gsub(/[^A-Za-z0-9_\.-]/, '')}"

    name = "#{name}.#{extension}" unless name.ends_with?(".#{extension}")

    name
  end

  def extension
    if lang == "coffeescript"
      "coffee"
    else
      "js"
    end
  end
end
