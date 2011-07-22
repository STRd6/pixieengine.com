require 'test_helper'

class SpritesControllerTest < ActionController::TestCase
  setup do
    @sprite = Factory :sprite
  end

  should "not be able to edit another's sprite" do
    get :edit, :id => @sprite.id
    assert_response :redirect
  end

  should "be able to view a sprite" do
    get :show, :id => @sprite.id
    assert_response :success
  end

  context "a logged in user" do
    setup do
      @user = log_in
      @sprite = Factory :sprite, :user => @user
    end

    should "be able to edit own sprite" do
      get :edit, :id => @sprite.id
      assert_response :success
    end

    should "be able to delete own sprite" do
      post :destroy, :id => @sprite.id
      assert_equal 'Sprite has been deleted.', flash[:notice]
      assert_response :redirect
    end
  end

  should "have correct routes" do
    assert_routing({ :path => "sprites", :method => :post }, { :controller => "sprites", :action => "create" })
    assert_routing({ :path => "sprites/new", :method => :get }, { :controller => "sprites", :action => "new" })
    assert_recognizes({ :controller => "sprites", :action => "new" }, '/pixel-editor')

    assert_routing({ :path => "sprites", :method => :get }, { :controller => "sprites", :action => "index" })
    assert_routing({ :path => "/sprites/1", :method => :get }, { :controller => "sprites", :action => "show", :id => "1" })
  end
end
