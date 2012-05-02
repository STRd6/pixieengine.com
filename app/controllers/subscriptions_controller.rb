class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :changed
  before_filter :require_user, :only => [:subscribe, :indie]

  def subscribe
    if params[:id]
      redirect_to User.find(params[:id]).subscribe_url
    else
      @title = "Subscribe - PixieEngine Game Creation Toolset"
    end
  end

  def changed
    subscriber_ids = params[:subscriber_ids].split(",")

    subscriber_ids.each do |subscriber_id|
      user = User.find(subscriber_id)
      user.refresh_from_spreedly if user
    end

    render :nothing => true
  end
end
