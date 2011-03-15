class AnimationsController < ApplicationController
  respond_to :html, :json
  layout "fullscreen"

  before_filter :require_user, :except => [:index]
  before_filter :filter_results, :only => [:index]

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
