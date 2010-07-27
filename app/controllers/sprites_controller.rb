class SpritesController < ResourceController::Base
  actions :all

  before_filter :require_owner, :only => [:edit, :update]
  before_filter :require_owner_or_admin, :only => [:destroy]

  create.before do
    @sprite.user = current_user
  end

  create.flash nil

  create.wants.html do
    unless sprite.user
      session[:saved_sprites] ||= {}
      session[:saved_sprites][sprite.id] = sprite.broadcast

      redirect_to login_path
    end
  end

  create.wants.js do
    if sprite.user
      render :update do |page|
        link = link_to "Sprite #{@sprite.id}", @sprite

        page.call "notify", "Saved as #{link}"
      end
    else
      session[:saved_sprites] ||= {}
      session[:saved_sprites][sprite.id] = sprite.broadcast

      render :update do |page|
        page.redirect_to login_path
      end
    end
  end

  new_action.wants.html do
    unless params[:width].to_i <= 0
      @width = params[:width].to_i
    end

    unless params[:height].to_i <= 0
      @height = params[:height].to_i
    end

    render :action => :pixie
  end

  def load
    @width = sprite.width
    @height = sprite.height
    @data = sprite.data[:frame_data]
    @parent_id = sprite.id

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
    end
  end

  private

  def collection
    sprites = Sprite

    if params[:tagged]
      sprites = Sprite.tagged_with(params[:tagged])
    end

    @collection ||= sprites.paginate(:page => params[:page], :order => 'id DESC')
  end

  helper_method :sprites
  def sprites
    return collection
  end

  helper_method :sprite
  def sprite
    return object
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
