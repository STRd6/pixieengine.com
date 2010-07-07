class UsersController < ResourceController::Base
  actions :all, :except => :destroy

  before_filter :require_current_user, :only => [:edit, :update]

  def remove_favorite
    sprite = Sprite.find(params[:id])
    current_user.remove_favorite(sprite)
    render :nothing => true
  end

  create do
    after do
      bingo!("registration_popup")
    end

    wants.json do
      flash[:notice] = nil
      render :json => {:status => "ok"}
    end

    failure do
      wants.json do
        flash[:error] = nil
        render :json => {
          :status => "error",
          :errors => user.errors.full_messages
        }
      end
    end
  end

  private

  def require_current_user
    unless current_user == object
      flash[:notice] = "You can only edit your own account"
      redirect_to root_url
      return false
    end
  end

  def object
    return @object if defined?(@object)

    if params[:id] == "current"
      @object = current_user
    else
      @object = User.find(params[:id])
    end
  end

  def user
    object
  end
  helper_method :user
end
