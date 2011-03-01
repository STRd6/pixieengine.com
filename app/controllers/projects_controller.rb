class ProjectsController < ApplicationController
  respond_to :html, :json

  before_filter :require_access, :only => [:save_file]

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
  end

  def show

  end

  def ide
    render :layout => "ide"
  end

  def save_file
    #TODO Save

    project.save_file(params[:path], params[:contents])

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
end
