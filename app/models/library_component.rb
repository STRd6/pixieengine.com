class LibraryComponent < ActiveRecord::Base
  belongs_to :library
  belongs_to :component_library, :class_name => "Library"
end
