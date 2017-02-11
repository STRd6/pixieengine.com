require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  should "get sitemap" do
    get :sitemap
    assert_response :success
  end

  should "get survey" do
    get :survey
    assert_response :success
  end

  should "have correct routes" do
    assert_routing({ :path => "survey", :method => :get }, { :controller => "home", :action => "survey" })
    assert_routing({ :path => "sitemap", :method => :get }, { :controller => "home", :action => "sitemap" })
  end
end
