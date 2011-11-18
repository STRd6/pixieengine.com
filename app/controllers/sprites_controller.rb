class SpritesController < ApplicationController
  respond_to :html, :json

  before_filter :require_owner_or_admin, :only => [:destroy, :edit, :update]
  before_filter :require_user, :only => [:add_tag, :remove_tag]

  def create
    @sprite = Sprite.create params[:sprite].merge(:user => current_user)

    track_event('create_sprite')

    respond_to do |format|
      format.html do
        if sprite.user
          redirect_to sprite
        else
          session[:saved_sprites] ||= {}
          session[:saved_sprites][sprite.id] = sprite.broadcast

          redirect_to sign_in_path
        end
      end
      format.json do
        if sprite.user
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

          render :json => { :redirect => sign_in_path }
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
    load_sprites

    respond_to do |format|
      format.html { }
      format.json { render :json => @sprites_data }
    end
  end

  def show
    respond_with(sprite) do |format|
      format.json { render :json }
    end
  end

  def edit
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

  def load_sprites
    per_page = 187

    @sprites = Sprite.paginate(
      :page => params[:page],
      :per_page => per_page,
    )

    current_page = @sprites.current_page
    total = @sprites.total_pages
    current_user_id = current_user ? current_user.id : nil

    @sprites_data = {
      :owner_id => nil,
      :current_user_id => current_user_id,
      :page => current_page,
      :per_page => per_page,
      :total => total,
      :models => @sprites
    }
  end

  def load
    @width = sprite.width
    @height = sprite.height
    @data = sprite.data[:frame_data]
    @parent_id = sprite.id
    @replay_data = sprite.load_replay_data if sprite.replayable?

    render :action => :pixie
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
      180
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
