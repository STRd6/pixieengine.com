class ProjectsController < ApplicationController
  respond_to :html, :json

  before_filter :require_access, :only => [:save_file, :tag_version, :edit, :update]

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

  def save_file
    if params[:contents_base64]
      contents = Base64.decode64(params[:contents_base64])
    else
      contents = params[:contents]
    end

    project.save_file(params[:path], contents, params[:message])

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
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
    Project::DEFAULT_CONFIG
  end
  helper_method :default_project_config
end
