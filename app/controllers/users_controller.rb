class UsersController < ApplicationController
  # this is no longer included in will_paginate core and we need it since
  # Project#editable is custom SQL rather than a scope and returns an array
  # instead of an ActiveRecord Relation.
  require 'will_paginate/array'
  respond_to :html, :json

  before_filter :require_user, :only => [:install_plugin]
  before_filter :require_current_user, :only => [:edit, :update, :add_to_collection]
  before_filter :prep_display_name, :only => :new

  REGISTERED_FLASH = "Account registered!"

  def prep_display_name
    @object = User.new

    email = session.delete(:email) || ''

    object.email ||= email

    if email.split('@').length > 0
      display_name = object.display_name = email.split("@").first.gsub(/[^A-Za-z0-9_-]/, '')
    else
      display_name = object.display_name = 'pixie_user'
    end

    # Gross uniqueness checking
    suffix = 0
    while User.where(:display_name => object.display_name).any?
      suffix += 1
      object.display_name = "#{display_name}-#{suffix}"
    end
  end

  def new
  end

  def index
    load_people

    respond_to do |format|
      format.html { }
      format.json { render :json => @people_data }
    end
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

  def load_people
    @people = collection

    current_page = @people.current_page
    total = @people.total_pages
    current_user_id = current_user ? current_user.id : nil

    @people_data = {
      :owner_id => nil,
      :current_user_id => current_user_id,
      :page => current_page,
      :per_page => per_page,
      :total => total,
      :models => @people
    }
  end

  def create
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
          redirect_to user, :notice => REGISTERED_FLASH
        end
        format.json { render :json => {:status => "ok"} }
      end
    else
      track_event('registration_error')

      respond_to do |format|
        format.html do
          render :action => :new
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
  end

  def edit
  end

  def update
    user.update_attributes(params[:user])

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

    # Filter must be white listed, always use filter helper
    if filter
      users = users.send(filter)
    end

    @collection ||= users.order("id DESC").search(params[:search]).paginate(:page => params[:page], :per_page => per_page)
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

    @object = User.find_by_display_name! params[:id]
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
