class TilemapsController < ApplicationController
  respond_to :html, :json
  layout "fullscreen"

  before_filter :filter_results, :only => [:index]

  def create
    @tilemap = Tilemap.new(params[:tilemap])
    @tilemap.user = current_user

    @tilemap.save

    respond_with(@tilemap) do |format|
      format.html do
      end
    end
  end

  def new
    respond_with(@tilemap) do |format|
      format.html do
      end
    end
  end

  def show
    @tilemap = Tilemap.find(params[:id])
  end

  def edit
    @tilemap = Tilemap.find(params[:id])
    @parent_id = @tilemap.id

    respond_with(@tilemap) do |format|
      format.html do
      end
    end
  end

  def index
  end

  def filter_results
    @tilemaps ||= if filter
      if filter == "own"
        Tilemap.for_user(current_user)
      else
        Tilemap.send(filter)
      end
    end.order("id DESC")
  end

  def filters
    ["own", "none"]
  end
end
