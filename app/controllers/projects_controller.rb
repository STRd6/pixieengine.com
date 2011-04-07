class ProjectsController < ApplicationController
  respond_to :html, :json

  PUBLIC_ACTIONS = [:index, :show, :hook, :info, :ide, :github_integration, :fullscreen, :demo]
  before_filter :require_user, :except => PUBLIC_ACTIONS
  before_filter :require_access, :except => PUBLIC_ACTIONS
  before_filter :filter_results, :only => [:index]

  def new
    @project = Project.new
  end

  def edit
  end

  def info
    fave_ids = [44, 12, 25, 14]
    tut_ids = [15, 56, 69, 14]

    @favorites = fave_ids.map do |id|
      App.find(id)
    end

    @tutorials = tut_ids.map do |id|
      App.find(id)
    end

    render :layout => "plain"
  end

  def update
    project.update_attributes(params[:project])

    respond_with(project) do |format|
      format.html do
        render :layout => "fullscreen"
      end
    end
  end

  def create
    @project = Project.new(params[:project])
    @project.user = current_user

    @project.save

    respond_with(@project) do |format|
      format.html do
        render :layout => "fullscreen"
      end
    end
  end

  def hook
    push = HashWithIndifferentAccess.new(JSON.parse(params[:payload]))

    url = push[:repository][:url]

    Project.with_url(url).each(&:git_pull)

    render :text => "ok"
  end

  def show
  end

  def ide
    @has_reg_popup = true

    render :layout => "ide"
  end

  def tag_version
    tag = params[:tag]
    message = params[:message].blank? ? "Tagged in browser at pixie.strd6.com" : params[:message]

    project.tag_version(tag, message)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def generate_docs
    project.generate_docs

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def update_libs
    project.update_libs

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def save_file
    if params[:contents_base64]
      contents = Base64.decode64(params[:contents_base64])
    else
      contents = params[:contents]
    end

    message = params[:message].presence

    project.save_file(params[:path], contents, message)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def filter_results
    @projects ||= if filter
      if current_user
        if filter == "own"
          Project.for_user(current_user)
        else
          Project.send(filter)
        end
      else
        Project.none
      end
    end.order("id DESC")
  end

  def filters
    ["own", "none"]
  end

  def demo?
    params[:id] == "demo"
  end

  private
  def object
    @project ||= if demo?
      if current_user
        current_user.demo_project
      else
        Project.find Project::DEMO_ID
      end
    else
      Project.find params[:id]
    end
  end
  helper_method :object

  def project
    object
  end
  helper_method :project

  def projects
    @projects ||= Project.all
  end
  helper_method :projects

  def default_project_config
    Project::DEFAULT_CONFIG.merge(:name => project.title)
  end
  helper_method :default_project_config
end
