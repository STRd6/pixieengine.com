class SoundsController < ApplicationController
  respond_to :html, :json

  before_filter :require_owner_or_admin, :only => [:destroy, :edit, :update]
  before_filter :require_user, :only => [:add_tag, :remove_tag]
  before_filter :filter_results, :only => [:index]

  def create
    @sound = Sound.new(params[:sound])
    @sound.user = current_user

    @sound.save
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
    @sounds ||= if current_user
      if filter == "own"
        Sound.for_user(current_user)
      elsif filter == "for_user"
        Sound.for_user(User.find(params[:user_id]))
      else
        Sound.send(filter)
      end
    else
      Sound
    end.order("id DESC").paginate(:page => params[:page], :per_page => per_page)
  end

  def filters
    ["own", "none", "for_user"]
  end

  def per_page
    24
  end

  private
  def object
    @sound ||= Sound.find params[:id]
  end
  helper_method :object

  def sound
    object
  end
  helper_method :sound

  def sounds
    @sounds ||= Sound.all
  end
  helper_method :sounds
end
