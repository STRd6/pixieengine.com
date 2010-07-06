require 'test_helper'

class LinksControllerTest < ActionController::TestCase
  context "links controller" do
    setup do
      @link = Factory :link

      get :track, :token => @link.token
    end

    should "redirect to target" do
      assert_redirected_to @link.target
    end

    should "set referrer" do
      assert_equal @link.user_id, session[:referrer_id]
    end

    should "track clicks(landings)" do
      #TODO
    end
  end
end
