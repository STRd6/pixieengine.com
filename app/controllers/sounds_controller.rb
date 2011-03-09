class SoundsController < ResourceController::Base
  actions :all
  respond_to :html, :json
  layout "fullscreen"

  before_filter :require_owner_or_admin, :only => [:destroy, :edit, :update]
  before_filter :require_user, :only => [:add_tag, :remove_tag]
  before_filter :filter_results, :only => [:index]

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
  end

  def filter_results
    @sounds ||= if filter
      if filter == "own"
        Sound.for_user(current_user)
      else
        Sound.send(filter)
      end
    end.order("id DESC")
  end

  def filters
    ["own", "none"]
  end

  private

  def sound
    object
  end
  helper_method :sound
end
