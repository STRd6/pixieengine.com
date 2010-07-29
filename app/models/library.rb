class Library < ActiveRecord::Base
  belongs_to :user

  has_many :library_scripts
  has_many :scripts, :through => :library_scripts

  has_many :library_components
  has_many :component_libraries, :through => :library_components

  def add_component_library(library)
    component_libraries << library
  end

  def add_script(script)
    scripts << script
  end

  def remove_script(script)
    library_scripts.find_by_script_id(script.id).destroy
  end

  def code
    #TODO: Include component libraries

    scripts.map(&:code).join(";\n")
  end

  def test
    scripts.map(&:test).join(";\n")
  end
end
