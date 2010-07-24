class Admin::FeedbacksController < AdminController
  resource_controller
  actions :only, :index

  def feedbacks
    collection
  end
  helper_method :feedbacks
end
