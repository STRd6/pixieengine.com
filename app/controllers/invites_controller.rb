class InvitesController < ApplicationController
  before_action :require_user, :only => [:new, :create]

  def new
    @invite = Invite.new
  end

  def create
    Invite.create invite_params

    track_event('send_email_invite')
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

  private
  def invite_params
    params[:invite].permit([:to, :email]).merge(:user => current_user)
  end
end
