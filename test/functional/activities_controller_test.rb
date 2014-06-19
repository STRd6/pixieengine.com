require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  context "a logged in user" do
    setup do
      @user = log_in
    end

    should "be able to get index" do
      get :index
      assert_response :success
    end
  end
end
