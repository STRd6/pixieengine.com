require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
  end

  context "a logged out user" do
    should "not be able to edit another's project" do
      get :edit, :id => @project.id

      assert_response :redirect
    end

    should "be able to view a project" do
      get :show, :id => @project.id
    end
  end

  context "a logged in user" do
    setup do
      @user = log_in
      @project = Factory :project, :user => @user
    end

    should "be able to edit own project" do
      get :edit, :id => @project.id

      assert_response :success
    end
  end
end
