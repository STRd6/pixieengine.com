class AnimationsController < ApplicationController
  respond_to :html, :json

  before_filter :require_user, :except => [:index]
  before_filter :filter_results, :only => [:index]

  def new
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

  def index
  end

  def filter_results
    @animations ||= if current_user
      if filter == "own"
        Animation.for_user(current_user)
      elsif filter == "for_user"
        Animation.for_user(User.find(params[:user_id]))
      else
        Animation.send(filter)
      end
    else
      Animation
    end.order("id DESC").paginate(:page => params[:page], :per_page => per_page)
  end

  def filters
    ["own", "none", "for_user"]
  end

  def per_page
    24
  end

  private
  def object
    @animation ||= animation.find params[:id]
  end
  helper_method :object

  def animation
    object
  end
  helper_method :animation

  def animations
    @animations ||= Animation.all
  end
  helper_method :animations
end

