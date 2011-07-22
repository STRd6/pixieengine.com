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
      assert_difference('User.count') do
        post :create, :user => { :display_name => 'TestUser', :email => "test@fake.com", :password => "abc123" }
      end

      assert_redirected_to user_path(assigns(:object))
    end

    should "be able to edit own profile" do
      get :edit, :id => @user.id

      assert_response :success
    end

    should "be redirected when visiting register_subscribe" do
      @user.paying = true

      get :register_subscribe

      assert_redirected_to user_path(@user)
    end
  end

  should "have correct routes" do
    assert_routing({ :path => "/people", :method => :post }, { :controller => "users", :action => "create" })
    assert_routing({ :path => "/people/new", :method => :get }, { :controller => "users", :action => "new" })
    assert_routing({ :path => "/people", :method => :get }, { :controller => "users", :action => "index" })
    assert_routing({ :path => "/people/1", :method => :get }, { :controller => "users", :action => "show", :id => "1" })
    assert_routing({ :path => "/people/1/edit", :method => :get }, { :controller => "users", :action => "edit", :id => "1" })
    assert_routing({ :path => "/people/1", :method => :put }, { :controller => "users", :action => "update", :id => "1" })
    assert_routing({ :path => "/people/1", :method => :delete }, { :controller => "users", :action => "destroy", :id => "1" })

    assert_routing({ :path => "/register_subscribe", :method => :get }, { :controller => "users", :action => "register_subscribe" })

    assert_routing({ :path => "/people/1/add_to_collection", :method => :post }, { :controller => "users", :action => "add_to_collection", :id => "1" })
    assert_routing({ :path => "/people/1/set_avatar", :method => :post }, { :controller => "users", :action => "set_avatar", :id => "1" })
    assert_routing({ :path => "/people/progress", :method => :get }, { :controller => "users", :action => "progress" })
    assert_routing({ :path => "/people/unsubscribe", :method => :get }, { :controller => "users", :action => "unsubscribe" })
    assert_routing({ :path => "/people/install_plugin", :method => :post }, { :controller => "users", :action => "install_plugin" })
    assert_routing({ :path => "/people/uninstall_plugin", :method => :post }, { :controller => "users", :action => "uninstall_plugin" })
    assert_routing({ :path => "/people/do_unsubscribe", :method => :post }, { :controller => "users", :action => "do_unsubscribe" })
  end
end
