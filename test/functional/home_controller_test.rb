require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  context "home controller" do
    setup do
      Factory :user, :display_name => nil

      Factory :sprite
      Factory :sprite, :title => nil
    end

    should "get sitemap" do
      get :sitemap
    end
  end
end
