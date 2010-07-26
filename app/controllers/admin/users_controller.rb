class Admin::UsersController < AdminController
  resource_controller
  actions :only, :index

  def users
    collection
  end
  helper_method :users
end
