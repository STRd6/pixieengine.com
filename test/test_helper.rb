ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/setup'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def log_in(user=nil)
    user ||= create :user

    @controller.stubs(:current_user).returns(user)

    return user
  end
end
