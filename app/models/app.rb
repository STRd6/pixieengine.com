class App < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, :class_name => "App"

  has_many :app_libraries
  has_many :libraries, :through => :app_libraries

  def library_code
    libraries.map(&:code).join(";\n")
  end

  def add_library(library)
    libraries << library
  end

  def remove_library(library)
    app_libraries.find_by_script_id(library.id).destroy
  end

  def template
    #TODO Not hardcoded
    '<canvas width="640" height="480"></canvas>'
  end
end
