class ProjectsController < ApplicationController
  respond_to :html, :json

  def fullscreen
    render :show, layout: "bare"
  end

  def show
    render layout: "bare"
  end
end
