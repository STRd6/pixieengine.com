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
      assert_response :success
    end

    should "be able to view a fullscreen project" do
      get :fullscreen, :id => @project.id
      assert_response :success
    end

    should "be able to view the ide" do
      get :ide, :id => @project.id
      assert_response :success
    end

    should "be able to view projects#info" do
      get :info
      assert_response :success
    end

    should "be able to view github_integration" do
      get :github_integration
      assert_response :success
    end
  end

  context "a logged in user" do
    setup do
      @user = log_in
      @project = Factory :project, :user => @user
      @another_user = Factory :user
    end

    should "should create a new Project" do
      assert_difference('Project.count') do
        post :create, :project => { :title => 'Test project', :description => "Description of the project.", :user => @user }
      end
      assert_redirected_to [:ide, assigns(:project)]
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

    should "have the option to fork another user's project" do
      @project.user = @another_user
      @project.save!

      get :ide, :id => @project.id

      assert_response :success
      assert_select '#fork'
    end
  end

  should "have correct routes" do
    assert_routing({ :path => "/projects", :method => :post }, { :controller => "projects", :action => "create" })
    assert_routing({ :path => "/projects/new", :method => :get }, { :controller => "projects", :action => "new" })
    assert_routing({ :path => "/projects", :method => :get }, { :controller => "projects", :action => "index" })
    assert_routing({ :path => "/projects/1", :method => :get }, { :controller => "projects", :action => "show", :id => "1" })
    assert_routing({ :path => "/projects/1/edit", :method => :get }, { :controller => "projects", :action => "edit", :id => "1" })
    assert_routing({ :path => "/projects/1", :method => :put }, { :controller => "projects", :action => "update", :id => "1" })
    assert_routing({ :path => "/projects/1", :method => :delete }, { :controller => "projects", :action => "destroy", :id => "1" })

    assert_recognizes({ :controller => "projects", :action => "info" }, '/begin')
    assert_recognizes({ :controller => "projects", :action => "arcade" }, '/arcade')
  end
end
