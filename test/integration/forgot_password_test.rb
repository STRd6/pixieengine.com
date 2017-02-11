require 'test_helper'

class ForgotPasswordTest < ActionDispatch::IntegrationTest
  setup do
    @user = create :user
  end

  test "forgot password link should work" do
    get "/password_resets/new"
    assert_response :success

    post "/password_resets", params: {
      email: @user.email
    }
  end
end
