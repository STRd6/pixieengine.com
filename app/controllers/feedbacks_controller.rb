class FeedbacksController < ResourceController::Base
  actions :all, :except => [:index, :show, :edit, :update, :destroy]

  create.response do |wants|
    wants.html { redirect_to :action => :thanks }
  end
end
