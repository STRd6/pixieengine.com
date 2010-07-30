class App < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, :class_name => "App"

  has_many :app_libraries
  has_many :libraries, :through => :app_libraries

  def library_code
    libraries.map(&:code).join(";\n")
  end
end
