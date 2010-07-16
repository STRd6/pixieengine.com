class CommentsController < ResourceController::Base
  actions :only, :create

  before_filter :require_user

  create.before do
    object.commenter = current_user
  end

  create.response do |wants|
    wants.html do
      redirect_to :back
    end
    wants.js { render :json => {:status => 'ok'} }
  end
end
