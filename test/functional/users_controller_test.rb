require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  context "a logged out user" do
    setup do
      @user = Factory :user
    end

    should "not be able to edit another's profile" do
      get :edit, :id => @user

      assert_response :redirect
    end

    should "be able to view a user" do
      get :show, :id => @user

      assert_response :success
    end

    should "be able to get to register_subscribe" do
      get :register_subscribe

      assert_response :success
    end
  end

  context "a logged in user" do
    setup do
      @user = log_in
    end

    should "should create a new User" do
      assert_difference 'User.count', +1 do
        post :create, :user => { :display_name => 'TestUser', :email => "test@fake.com", :password => "abc123" }
      end

      assert_redirected_to user_path(assigns(:object))
    end

    should "be able to edit own profile" do
      get :edit, :id => @user

      assert_routing({ :path => "/#{@user.display_name}/edit"}, { :controller => "users", :action => "edit", :id => @user.display_name})
    end

    should "be redirected when visiting register_subscribe" do
      @user.paying = true

      get :register_subscribe

      assert_redirected_to user_path(@user)
    end

    should "be vain" do
      assert_routing({ :path => "/#{@user.display_name}"}, { :controller => "users", :action => "show", :id => @user.display_name})
    end
  end
end
