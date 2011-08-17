class AnimationsController < ApplicationController
  respond_to :html, :json

  before_filter :require_user, :except => [:index]

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

  def download
    if params[:export_csv_data]
      send_data params[:export_csv_data], :type =>"plain/text", :filename => "animation.txt"
    end

    if params[:export_json_data]
      send_data params[:export_json_data], :type =>"application/json", :filename => "animation.json"
    end
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

