class LeadsController < ApplicationController
  respond_to :html, :json

  def create
    lead = Lead.create params[:lead]

    render :json => lead, :callback => params[:callback]
  end
end
