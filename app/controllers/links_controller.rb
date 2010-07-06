class LinksController < ApplicationController
  def track
    link = Link.find_by_token(params[:token])

    #TODO: Track click

    # Set referrer
    session[:referrer_id] = link.user_id

    redirect_to link.target
  end
end
