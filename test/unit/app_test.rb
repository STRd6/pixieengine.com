require 'test_helper'

class AppTest < ActiveSupport::TestCase
  setup do
    @app = Factory :app
  end

  context "User Access:" do
    context "members" do
      setup do
        @app_member = Factory :user
        AppMember.create(:app => @app, :user => @app_member)
      end

      should "have access to app" do
        assert @app.has_access?(@app_member)
      end
    end

    context "non members" do
      setup do
        @non_member = Factory :user
      end

      should "not have access to app" do
        assert !@app.has_access?(@non_member)
      end
    end
  end
end
