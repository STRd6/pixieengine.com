require 'test_helper'

class ChatsControllerTest < ActionController::TestCase
  setup do
    @user = log_in
  end

  should "should create a new Chat" do
    assert_difference('Chat.count') do
      post :create, :body => 'This is a chat msg'
    end
  end
end
