class AnimationsController < ApplicationController
  def new
    @user_sprites = (current_user) ? current_user.sprites : []
    render :layout => "fullscreen"
  end

  def create
  end

  def show
  end

  def edit
    @user_sprites = (current_user) ? current_user.sprites : []
    render :layout => "fullscreen"
  end

  def index
  end

end
