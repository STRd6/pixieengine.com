class Treatment < ActiveRecord::Base
  belongs_to :experiment
  belongs_to :user

  before_create do
    self.control = (rand(2) == 0)

    true # Don't want to return false on the last line!
  end
end
