class UsersController < ResourceController::Base
  actions :all, :except => :destroy

  before_filter :require_current_user, :only => [:edit, :update]

  def remove_favorite
    sprite = Sprite.find(params[:id])
    current_user.remove_favorite(sprite)
    render :nothing => true
  end

  def create
    @object = User.new(params[:user])
    @object.save do |result|
      if result
        bingo!("registration_popup")

        respond_to do |format|
          format.html do
            flash[:notice] = "Account registered!"
            redirect_back_or_default account_url
          end
          format.json { render :json => {:status => "ok"} }
        end

      else
        respond_to do |format|
          format.html { render :action => :new }
          format.json do
            render :json => {
              :status => "error",
              :errors => user.errors.full_messages
            }
          end
        end
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
