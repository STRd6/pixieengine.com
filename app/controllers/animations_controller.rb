class AnimationsController < ApplicationController
  respond_to :html, :json

  def new
    respond_with(@animation) do |format|
      format.html do
        @user_sprites = current_user.sprites || []
        render :layout => "fullscreen"
      end
    end
  end

  def create
    @animation = Animation.new(params[:animation])
    @animation.user = current_user

    @animation.save

    respond_with(@animation) do |format|
      format.html do
        render :layout => "fullscreen"
      end
    end
  end

  def show
    @animation = Animation.find(params[:id])
  end

  def edit
    @animation = Animation.find(params[:id])

    respond_with(@animation) do |format|
      format.html do
        render :layout => "fullscreen"
      end
    end
  end

  def index
    @animations = Animation.all
  end
end
