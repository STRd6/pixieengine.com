class User < ActiveRecord::Base
  acts_as_authentic

  before_validation(:on => :create) do
    self.reset_password
  end
end
