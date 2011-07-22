require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  should "get about" do
    get :about
    assert_response :success
  end

  should "get sitemap" do
    get :sitemap
    assert_response :success
  end

  should "get survey" do
    get :survey
    assert_response :success
  end

  should "get jukebox" do
    get :jukebox
    assert_response :success
  end

  should "have correct routes" do
    assert_routing({ :path => "jukebox", :method => :get }, { :controller => "home", :action => "jukebox" })
    assert_routing({ :path => "about", :method => :get }, { :controller => "home", :action => "about" })
    assert_routing({ :path => "survey", :method => :get }, { :controller => "home", :action => "survey" })
    assert_routing({ :path => "sitemap", :method => :get }, { :controller => "home", :action => "sitemap" })
  end
end
