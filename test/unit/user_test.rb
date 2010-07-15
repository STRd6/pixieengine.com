require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = Factory :user
  end

  # Replace this with your real tests.
  test "the factory" do
    assert @user
  end

  should "send password email on create" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Factory :user
    end
  end
end
