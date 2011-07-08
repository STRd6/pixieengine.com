require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = Factory :user
  end

  context "a logged out user" do
    should "not be able to edit another's profile" do
      get :edit, :id => @user.id

      assert_response :redirect
    end

    should "be able to view a user" do
      get :show, :id => @user.id
    end
  end

  context "a logged in user" do
    setup do
      @user = log_in
    end

    should "be able to edit own profile" do
      get :edit, :id => @user.id

      assert_response :success
    end
  end
end
