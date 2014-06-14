require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  context "a project" do
    setup do
      @id = 106
    end

    context "when logged out" do
      should "be able to view" do
        get :show, :id => @id
        assert_response :success
      end

      should "be able to view fullscreen" do
        get :fullscreen, :id => @id
        assert_response :success
      end
    end
  end

  should "be able to view projects#info" do
    get :info
    assert_response :success
  end

  should "be able to view github_integration" do
    get :github_integration
    assert_response :success
  end

  context "a logged in user" do
    setup do
      @user = log_in
    end

    context "with a project" do
      setup do
        @id = 106
      end

      should "be able to view the project" do
        get :show, :id => @id
        assert_response :success
      end
    end
  end
end
