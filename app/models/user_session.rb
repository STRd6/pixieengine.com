class UserSession < Authlogic::Session::Base
  attr_accessor :login
end
