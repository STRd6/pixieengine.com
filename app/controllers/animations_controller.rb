class AnimationsController < ApplicationController
  respond_to :html, :json
  layout "fullscreen"

  before_filter :require_user

  def new
    respond_with(@animation) do |format|
      format.html do
        @user_sprites = current_user.sprites || []
      end
    end
  end

  def create
    @animation = Animation.new(params[:animation])
    @animation.user = current_user

    @animation.save

    respond_with(@animation) do |format|
      format.html do
      end
    end
  end

  def edit
    @animation = Animation.find(params[:id])

    respond_with(@animation) do |format|
      format.html do
        @user_sprites = current_user.sprites || []
      end
    end
  end

  def index
    @animations = Animation.all
  end
end
