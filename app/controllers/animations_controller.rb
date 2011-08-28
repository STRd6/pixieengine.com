class AnimationsController < ApplicationController
  respond_to :html, :json

  def new
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

