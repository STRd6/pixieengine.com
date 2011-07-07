class SpritesController < ApplicationController
  respond_to :html, :json

  before_filter :require_owner_or_admin, :only => [:destroy, :edit, :update]
  before_filter :require_user, :only => [:add_tag, :remove_tag]

  def create
    @sprite = Sprite.create params[:sprite].merge(:user => current_user)

    respond_to do |format|
      format.html do
        if sprite.user
          redirect_to sprite
        else
          session[:saved_sprites] ||= {}
          session[:saved_sprites][sprite.id] = sprite.broadcast

          redirect_to login_path
        end
      end
      format.json do
        if sprite.user
          Event.create(:user => current_user, :name => "save_sprite")

          render :json => {
            :sprite => {
              :id => @sprite.id,
              :title => @sprite.title,
              :app_sprite_id => @sprite.app_sprite_id,
              :src => @sprite.image.url
            }
          }
        else
          session[:saved_sprites] ||= {}
          session[:saved_sprites][sprite.id] = sprite.broadcast

          render :json => { :redirect => login_path }
        end
      end
    end
  end

  def new
    unless params[:width].to_i <= 0
      @width = [params[:width].to_i, Sprite::MAX_LENGTH].min
    end

    unless params[:height].to_i <= 0
      @height = [params[:height].to_i, Sprite::MAX_LENGTH].min
    end

    @sprite = Sprite.new

    render :action => :pixie
  end

  def index
    @top_nav = true

    respond_with(sprites) do |format|
      format.json { render :json }
    end
  end

  def show
    @top_nav = true
  end

  def edit
    @top_nav = true
  end

  def destroy
    @sprite = Sprite.find(params[:id])
    @sprite.destroy
    flash[:notice] = "Sprite has been deleted."
    respond_with(@sprite)
  end

  def update
    @sprite = Sprite.find(params[:id])

    @sprite.update_attributes(params[:sprite])

    respond_with(@sprite) do |format|
      format.json { render :json => {
          :id => @sprite.id,
          :title => @sprite.display_name,
          :description => @sprite.description || "",
          :img => @sprite.image.url,
          :author => (@sprite.user) ? @sprite.user.display_name : "Anonymous",
          :author_id => @sprite.user_id
        }
      }
    end
  end

  def load
    @width = sprite.width
    @height = sprite.height
    @data = sprite.data[:frame_data]
    @parent_id = sprite.id
    @replay_data = sprite.load_replay_data if sprite.replayable?

    render :action => :pixie
  end

  def load_url
    if params[:url].blank?
      # Render form
    else
      sprite = Sprite.data_from_path(params[:url])

      @width = sprite[:width]
      @height = sprite[:height]
      @data = sprite[:frame_data]

      render :action => :pixie
    end
  end

  def import
    @sprite = Sprite.new

    @sprite.user = current_user
    if @sprite.update_attributes(params[:sprite])
      redirect_to @sprite
    else
      # Errors
      render :action => :upload
    end
  end

  def add_tag
    sprite.add_tag(params[:tag])

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
    end
  end

  def remove_tag
    sprite.remove_tag(params[:tag])

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
    end
  end

  private

  def collection
    @collection ||= if params[:tagged]
      Sprite.tagged_with(params[:tagged]).order("id DESC").paginate(:page => params[:page], :per_page => per_page)
    else
      Sprite.order("id DESC").paginate(:page => params[:page], :per_page => per_page)
    end
  end

  def per_page
    if params[:per_page].blank?
      172
    else
      params[:per_page].to_i
    end
  end

  helper_method :sprites
  def sprites
    return collection
  end

  helper_method :sprite
  def sprite
    return @sprite ||= Sprite.find(params[:id])
  end

  def object
    sprite
  end

  helper_method :installed_tools
  def installed_tools
    if current_user
      current_user.installed_plugins
    else
      []
    end
  end
end
