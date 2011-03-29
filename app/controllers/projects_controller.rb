class ProjectsController < ApplicationController
  respond_to :html, :json

  before_filter :require_user, :except => [:index, :show, :hook, :info, :github_integration]
  before_filter :require_access, :only => [:save_file, :tag_version, :edit, :update, :generate_docs]
  before_filter :filter_results, :only => [:index]

  def new
    @project = Project.new
  end

  def edit
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

  private
  def object
    @project ||= Project.find params[:id]
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
