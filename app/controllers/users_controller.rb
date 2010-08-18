class UsersController < ResourceController::Base
  actions :all, :except => :destroy

  before_filter :require_user, :only => [:install_plugin]
  before_filter :require_current_user, :only => [:edit, :update, :add_to_collection]

  new_action.before do
    email = session.delete(:email) || ''

    object.email ||= email
    object.display_name = email[0..((email.index('@') || 0) - 1)]
  end

  def remove_favorite
    sprite = Sprite.find(params[:id])
    current_user.remove_favorite(sprite)
    render :nothing => true
  end

  def create
    @object = User.new(params[:user])

    @object.referrer_id = session[:referrer_id]

    @object.save do |result|
      if result
        session.delete(:referrer_id)

        bingo!("registration_popup")
        bingo!("load_pic")
        bingo!("login_after")

        save_sprites_to_user(user)

        respond_to do |format|
          format.html do
            @registered = true
            flash[:notice] = "Account registered!"
            redirect_to user
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
    collectables = [Sprite, Collection, Plugin, Script, User, Library]

    collectable_id = params[:collectable_id].to_i
    collectable_type = params[:collectable_type].constantize
    collection_name = params[:collection_name]

    if collectables.include? collectable_type
      user.add_to_collection(collectable_type.find(collectable_id), collection_name)
    end

    render :nothing => true
  end

  def install_plugin
    current_user.install_plugin(Plugin.find(params[:plugin_id]))

    flash[:notice] = "Plugin installed"
    redirect_to :back
  end

  def uninstall_plugin
    current_user.uninstall_plugin(Plugin.find(params[:plugin_id]))

    flash[:notice] = "Plugin uninstalled"
    redirect_to :back
  end
  
  def do_unsubscribe
    if params[:id]
      user = User.find(params[:id])
    elsif params[:email]
      user = User.find_by_email(params[:email])
    end
    
    if user
      user.update_attribute(:subscribed, false)
    end

    flash[:notice] = "You have been unsubscribed"
    redirect_to root_path
  end

  private

  def collection
    users = User

    @collection ||= users.all(:order => 'id ASC')
  end

  def require_current_user
    unless current_user?
      flash[:notice] = "You can only edit your own account"
      redirect_to root_url
    end
  end

  def current_user?
    current_user == object
  end
  helper_method :current_user?

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
