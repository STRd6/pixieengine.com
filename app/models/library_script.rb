class LibraryScript < ActiveRecord::Base
  belongs_to :library
  belongs_to :script
end
