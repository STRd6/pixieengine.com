require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  context "a project" do
    setup do
      @project = Factory :project
    end

    context "when logged out" do
      should "not be able to be editted" do
        get :edit, :id => @project.id
        assert_response :redirect
      end

      should "be able to view" do
        get :show, :id => @project.id
        assert_response :success
      end

      should "be able to view fullscreen" do
        get :fullscreen, :id => @project.id
        assert_response :success
      end

      should "be able to view the ide" do
        get :ide, :id => @project.id
        assert_response :success
      end

      should "be able to view widget" do
        get :widget, :id => @project.id
        assert_response :success
      end
    end

    context "that is deleted" do
      setup do
        @project.destroy
      end

      should "not be able to view" do
        assert_raise(ActiveRecord::RecordNotFound) do
          get :show, :id => @project.id
        end
      end

      should "not be viewable in the IDE" do
        assert_raise(ActiveRecord::RecordNotFound) do
          get :ide, :id => @project.id
        end
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

    should "should create a new Project" do
      assert_difference('Project.count') do
        post :create, :project => { :title => 'Test project', :description => "Description of the project." }
      end
      assert_redirected_to [:ide, assigns(:project)]
    end

    context "with a project" do
      setup do
        @project = Factory :project, :user => @user
      end

      should "be able to edit own project" do
        get :edit, :id => @project.id
        assert_response :success
      end

      should "have the option to save your own project" do
        get :ide, :id => @project.id
        assert_response :success
        assert_select '#save'
      end
    end
  end
end
