require 'test_helper'

class ChatsControllerTest < ActionController::TestCase
  setup do
    @user = log_in
  end

  should "create a new Chat" do
    assert_difference 'Chat.count', +1 do
      post :create, :body => 'This is a chat msg'
    end
  end

  # should "get recent" do
  #   get :recent
  #
  #   assert_response :not_modified
  # end
  #
  # should "get active_users" do
  #   get :active_users
  #
  #   assert_response :not_modified
  # end

  should "have the correct routes" do
    assert_routing({ :path => "chats", :method => :post }, { :controller => "chats", :action => "create" })
    assert_routing({ :path => "chats/recent", :method => :get }, { :controller => "chats", :action => "recent" })
    assert_routing({ :path => "chats/active_users", :method => :get }, { :controller => "chats", :action => "active_users" })
  end
end
