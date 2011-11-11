class UsersController < ApplicationController
  respond_to :html, :json

  before_filter :require_user, :only => [:install_plugin]
  before_filter :require_current_user, :only => [:edit, :update, :add_to_collection]
  before_filter :prep_display_name, :only => :new

  REGISTERED_FLASH = "Account registered!"

  def prep_display_name
    @object = User.new

    email = session.delete(:email) || ''

    object.email ||= email
    object.display_name = email[0..((email.index('@') || 0) - 1)]
  end

  def new
  end

  def index
  end

  def remove_favorite
    sprite = Sprite.find(params[:id])
    current_user.remove_favorite(sprite)
    render :nothing => true
  end

  def set_avatar
    sprite = Sprite.find(params[:sprite_id])
    current_user.set_avatar(sprite)
    render :nothing => true
  end

  def sprites
    per_page = Sprite.per_page
    user = User.find params[:id]

    load_user_sprites(user, per_page)

    respond_to do |format|
      format.json { render :json => @user_sprites_data }
    end
  end

  def register_subscribe
    @hide_chat = true

    if current_user
      if current_user.paying
        redirect_back_or_default current_user
      else
        redirect_to current_user.subscribe_url
      end
    end

    @object = User.new

    @hide_dock = true
  end

  def create
    subscribe = params[:subscribe]

    new_game_bonus = params[:new_game]
    new_game_plan_id = 16362

    @object = User.new(params[:user])

    @object.referrer_id = session[:referrer_id]

    if @object.save
      session.delete(:referrer_id)

      save_sprites_to_user(user)

      track_event('register')

      respond_to do |format|
        format.html do
          @registered = true
          if subscribe
            plan_id = new_game_plan_id if new_game_bonus
            redirect_to user.subscribe_url(plan_id)
          else
            redirect_to user, :notice => REGISTERED_FLASH
          end
        end
        format.json { render :json => {:status => "ok"} }
      end
    else
      track_event('registration_error')

      respond_to do |format|
        format.html do
          if subscribe
            render :action => :register_subscribe
          else
            render :action => :new
          end

        end
        format.json do
          render :json => {
            :status => "error",
            :errors => user.errors.full_messages
          }
        end
      end
    end
  end

  def show
    @title = "#{user.display_name} - PixieEngine Game Creation Toolset"
    user = User.find params[:id]

    per_page = Sprite.per_page

    load_user_sprites(user, per_page)
  end

  def edit
  end

  def update
    user.update_attributes params[:user]
    flash[:notice] = "Account information updated."

    respond_with user
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

    redirect_to :back, :notice => "Plugin installed"
  end

  def uninstall_plugin
    current_user.uninstall_plugin(Plugin.find(params[:plugin_id]))

    redirect_to :back, :notice => "Plugin uninstalled"
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

    redirect_to root_path, :notice => "You have been unsubscribed"
  end

  private

  def collection
    users = User

    if filter
      users = users.send(filter)
    end

    @collection ||= users.order("id DESC").paginate(:page => params[:page], :per_page => per_page)
  end

  def load_user_sprites(user, per_page)
    @user_sprites = user.sprites.paginate(
      :page => params[:page],
      :per_page => per_page,
    )

    current_page = @user_sprites.current_page
    total = @user_sprites.total_pages
    current_user_id = current_user ? current_user.id : nil

    @user_sprites_data = {
      :sprite_owner_id => user.id,
      :current_user_id => current_user_id,
      :page => current_page,
      :per_page => per_page,
      :total => total,
      :models => @user_sprites
    }
  end

  def require_current_user
    unless current_user?
      redirect_to root_url, :notice => "You can only edit your own account"
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

  def users
    collection
  end
  helper_method :users

  def filters
    ["featured", "none"]
  end

  def gallery_filters
    [
      ["Featured", :featured],
      ["All", :none],
    ]
  end
  helper_method :gallery_filters
end
