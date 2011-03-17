class AnimationsController < ApplicationController
  respond_to :html, :json
  layout "fullscreen"

  before_filter :require_user, :except => [:index]
  before_filter :filter_results, :only => [:index]

  def new
    @user_sprites = current_user.sprites

    respond_with(@animation)
  end

  def create
    @animation = Animation.new(params[:animation])
    @animation.user = current_user

    @animation.save

    respond_with(@animation)
  end

  def edit
    @animation = Animation.find(params[:id])
    @user_sprites = current_user.sprites

    respond_with(@animation)
  end

  def filter_results
    @animations ||= if filter
      if current_user
        if filter == "own"
          Animation.for_user(current_user)
        else
          Animation.send(filter)
        end
      else
        Animation.none
      end
    end.order("id DESC")
  end

  def filters
    ["own", "none"]
  end
end

