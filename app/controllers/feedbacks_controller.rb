class FeedbacksController < ResourceController::Base
  actions :all, :except => [:edit, :update, :destroy]

end
