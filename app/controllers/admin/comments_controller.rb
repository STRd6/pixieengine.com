class Admin::CommentsController < AdminController
  resource_controller
  actions :only, :index

  def comments
    collection
  end
  helper_method :comments
end
