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

  should "have correct routes" do
    assert_routing({ :path => "/subscribe", :method => :get }, { :controller => "subscriptions", :action => "subscribe" })
    assert_routing({ :path => "/subscriptions/thanks", :method => :get }, { :controller => "subscriptions", :action => "thanks" })
    assert_routing({ :path => "/subscriptions/changed", :method => :post }, { :controller => "subscriptions", :action => "changed" })
  end
end
