class CollectionsController < ResourceController::Base
  actions :all, :except => [:edit, :update, :destroy]

  private

  helper_method :collections
  def collections
    collection
  end

  def user
    object.user
  end
  helper_method :user
end
