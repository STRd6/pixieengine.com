class TilemapsController < ApplicationController
  respond_to :html, :json

  def create
    @tilemap = Tilemap.new(params[:tilemap])

    @tilemap.save

    respond_with(@tilemap)
  end
end
