class InvitesController < ResourceController::Base
  actions :only, :create, :new

  before_filter :require_user

  create.before do
    @invite.user = current_user
  end

  create.response do |wants|
    wants.html do
      flash[:notice] =  "Your friend will receive the message shortly"
      redirect_to root_path
    end
  end
end
