class TilemapsController < ApplicationController
  respond_to :html, :json

  def create
    @tilemap = Tilemap.new(params[:tilemap])

    @tilemap.save

    respond_with(@tilemap)
  end

  def show
    @tilemap = Tilemap.find(params[:id])
  end

  def edit
    @tilemap = Tilemap.find(params[:id])
    @parent_id = @tilemap.id
  end
end
