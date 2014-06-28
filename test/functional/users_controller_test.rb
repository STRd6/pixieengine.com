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

    should "be able to view own profile" do
      get :show, :id => @user
    end

    context "with a comment on a sprite that has been deleted" do
      setup do
        comment = Factory :comment, :commentee => @user
        comment.commentable.destroy()

        @user.reload
        assert_equal 1, @user.activity_updates.size
      end

      should "be able to view own profile" do
        get :show, :id => @user
      end
    end

    context "with a sprite that has been deleted" do
      setup do
        sprite = Factory :sprite
        sprite.destroy()
        @user.follow sprite.user

        @user.reload
        assert_equal 1, @user.friends_activity.size
      end

      should "be able to view own profile" do
        get :show, :id => @user
      end
    end

    should "be able to edit own profile" do
      get :edit, :id => @user

      assert_routing({ :path => "/#{@user.display_name}/edit"}, { :controller => "users", :action => "edit", :id => @user.display_name})
    end

    should "be vain" do
      assert_routing({ :path => "/#{@user.display_name}"}, { :controller => "users", :action => "show", :id => @user.display_name})
    end
  end
end
