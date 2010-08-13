class SpritesController < ResourceController::Base
  actions :all

  before_filter :require_owner_or_admin, :only => [:destroy, :edit, :update]
  before_filter :require_user, :only => [:add_tag, :remove_tag]

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
      @width = [params[:width].to_i, Sprite::MAX_LENGTH].min
    end

    unless params[:height].to_i <= 0
      @height = [params[:height].to_i, Sprite::MAX_LENGTH].min
    end

    render :action => :pixie
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
      sprites = Sprite.tagged_with(params[:tagged]).paginate(:page => params[:page], :per_page => Sprite.per_page, :order => 'id DESC')
    elsif params[:q]
      sprites = Sprite.search(params[:q], :page => params[:page], :per_page => Sprite.per_page)
    else
      Sprite.paginate(:page => params[:page], :per_page => Sprite.per_page, :order => 'id DESC')
    end
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
