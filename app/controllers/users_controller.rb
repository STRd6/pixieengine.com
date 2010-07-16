class UsersController < ResourceController::Base
  actions :all, :except => :destroy

  before_filter :require_current_user, :only => [:edit, :update, :add_to_collection]

  new_action.before do
    object.email ||= session[:email]
    session[:email] = nil
  end

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
        bingo!("load_pic")
        bingo!("login_after")

        save_sprites_to_user

        respond_to do |format|
          format.html do
            @registered = true
            flash[:notice] = "Account registered!"
            redirect_back_or_default url_for(@object)
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

  def add_to_collection
    collectables = [Sprite, Collection]

    collectable_id = params[:collectable_id].to_i
    collectable_type = params[:collectable_type].constantize
    collection_name = params[:collection_name]

    if collectables.include? collectable_type
      user.add_to_collection(collectable_type.find(collectable_id), collection_name)
    end

    render :nothing => true
  end

  private

  def save_sprites_to_user
    (session[:saved_sprites] || {}).each do |sprite_id, broadcast|
      sprite = Sprite.find(sprite_id)
      sprite.update_attribute(:user, user)
      if broadcast == "1"
        sprite.broadcast_link
      end
    end

    session[:saved_sprites] = nil
  end

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
