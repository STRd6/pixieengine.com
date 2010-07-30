class AppLibrary < ActiveRecord::Base
  belongs_to :app
  belongs_to :library
end
