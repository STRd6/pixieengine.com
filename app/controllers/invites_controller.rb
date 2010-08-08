class InvitesController < ResourceController::Base
  actions :create, :new

  before_filter :require_user, :only => [:new, :create]

  create.before do
    @invite.user = current_user
  end

  create.response do |wants|
    wants.html do
      flash[:notice] =  "Your friend will receive the message shortly"
      redirect_to root_path
    end
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
