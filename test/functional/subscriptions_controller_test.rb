require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  context "logged out users" do
    should "redirect to login page when they go to the subscribe page" do
      get :subscribe

      assert_redirected_to :controller => "user_sessions", :action => "new"
    end
  end

  context "logged in users" do
    setup do
      @user = log_in
    end

    should "be able to visit the subscribe page" do
      get :subscribe

      assert_response :success
    end
  end
end
