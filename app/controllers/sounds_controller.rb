class SoundsController < ResourceController::Base
  actions :all

  before_filter :require_owner_or_admin, :only => [:destroy, :edit, :update]
  before_filter :require_user, :only => [:add_tag, :remove_tag]

  create.before do
    sound.user = current_user
  end

  private

  def sound
    object
  end
  helper_method :sound
end
