class Developer::AppSoundsController < ApplicationController
  resource_controller

  before_filter :require_access, :only => [:edit, :update, :destroy]

  def create
    if params[:sound]
      sound = Sound.new(params[:sound])
      sound.user = current_user

      params[:app_sound].sound = sound
    end

    app_sound = AppSound.create! params[:app_sound]

    render :json => {
      :app_sound => {
        :id => app_sound.id,
        :sound_id => app_sound.sound_id
      }
    }
  end

  def update
    render :json => {:updated => true}
  end
end
