class Developer::AppSpritesController < ApplicationController
  resource_controller

  before_filter :require_access, :only => [:edit, :update, :destroy]

  def create
    if params[:sprite]
      sprite = Sprite.new(params[:sprite])
      sprite.user = current_user

      params[:app_sprite].sprite = sprite
    end

    app_sprite = AppSprite.create! params[:app_sprite]

    render :json => {
      :app_sprite => {
        :id => app_sprite.id,
        :sprite_id => app_sprite.sprite_id
      }
    }
  end

  def update
    render :json => {:updated => true}
  end
end
