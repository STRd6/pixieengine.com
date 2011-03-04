class SoundsController < ResourceController::Base
  actions :all
  respond_to :html, :json
  layout "fullscreen"

  before_filter :require_owner_or_admin, :only => [:destroy, :edit, :update]
  before_filter :require_user, :only => [:add_tag, :remove_tag]

  create.before do
    sound.user = current_user
  end

  def new
    respond_with(@sound) do |format|
      format.html do
      end
    end
  end

  def index
    @sounds = Sound.order("id DESC").all
  end

  private

  def sound
    object
  end
  helper_method :sound
end
