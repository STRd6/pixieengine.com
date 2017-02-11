require 'test_helper'

class InvitesControllerTest < ActionController::TestCase
  context "a logged in user" do
    setup do
      @user = log_in
    end

    should "be able to create an invite" do
      assert_difference 'Invite.count', +1 do
        post :create, params: {
          :invite => { 
            :to => 'Joe TestUser', 
            :email => "test@fake.com" 
          }
        }
      end
    end
  end
end
