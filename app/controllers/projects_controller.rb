class ProjectsController < ApplicationController
  respond_to :html, :json

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
end
