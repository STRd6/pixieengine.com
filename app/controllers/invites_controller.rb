class InvitesController < ApplicationController
  before_filter :require_user, :only => [:new, :create]

  def new
    @invite = Invite.new
  end

  def create
    Invite.create params[:invite].merge(:user => current_user)

    Event.create(:user => current_user, :name => "invite_friend")
    redirect_to current_user, :notice => "Your friend will receive the message shortly"
  end

  def track
    invite = Invite.find_by_token(params[:token])

    #TODO: Track click

    # Set referrer
    session[:referrer_id] = invite.user_id
    session[:email] = invite.email

    redirect_to root_path
  end
end
