class AnimationsController < ApplicationController
  respond_to :html, :json

  def new
  end

  def download
    csv_data, json_data = params.values_at(:export_csv_data, :export_json_data)

    if csv_data
      send_data csv_data, :type =>"plain/text", :filename => "animation.txt"
    end

    if json_data
      send_data json_data, :type =>"application/json", :filename => "animation.json"
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

