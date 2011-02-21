class ProjectsController < ApplicationController
  respond_to :html, :json

  before_filter :require_access, :only => [:save_file]

  def new
    @project = Project.new
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

  def show
    @project = Project.find params[:id]
  end

  def ide
    @project = Project.find params[:id]

    render :layout => "ide"
  end

  def save_file
    #TODO Save

    project.save_file(params[:path], params[:contents])

    respond_to do |format|
      format.json do
        render :text => "ok"
      end
    end
  end

  private
  def object
    @object ||= Project.find params[:id]
  end
  helper_method :object

  def project
    object
  end
end
