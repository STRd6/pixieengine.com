class SpritesController < ApplicationController
  respond_to :html, :json

  before_action :require_owner_or_admin, :only => [
    :destroy,
    :edit,
    :update
  ]
  before_action :require_user, :only => [
    :add_tag,
    :remove_tag,
    :add_favorite,
    :remove_favorite
  ]

  before_action :require_admin, only: [ :suppress ]

  def create
    @sprite = Sprite.create! sprite_params

    track_event('create_sprite')

    respond_to do |format|
      format.html do
        if sprite.user
          redirect_to sprite
        else
          session[:saved_sprites] ||= {}
          session[:saved_sprites][sprite.id] = 0

          redirect_to sign_in_path
        end
      end
      format.json do
        if sprite.user
          render :json => {
            :sprite => {
              :id => @sprite.id,
              :title => @sprite.title,
              :src => @sprite.image_url
            }
          }
        else
          session[:saved_sprites] ||= {}
          session[:saved_sprites][sprite.id] = 0

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

  def new_editor
  end

  def collage
  end

  def suppress
   sprite.suppress!
   redirect_back fallback_location: sprites_path
  end

  def index
    @sprites = collection

    respond_with(@sprites) do |format|
      format.json { render :json }
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

    @sprite.update_attributes(sprite_params)

    respond_with(@sprite)
  end

  def load
    @source_url = sprite.image_url + "?-_-"
    @parent_id = sprite.id
    @parent_url = sprite.parent ? sprite.parent.image_url + "?-_-" : nil
    @replay_url = sprite.replay_url ? sprite.replay_url + "?-_-" : nil

    @width = sprite.width
    @height = sprite.height

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
    sprite.tag_list.add(params[:tag])
    sprite.save!

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html { redirect_back_or_root }
    end
  end

  def remove_tag
    sprite.tag_list.remove(params[:tag])
    sprite.save!

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html { redirect_back_or_root }
    end
  end

  def add_favorite
    current_user.add_favorite(sprite)

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
    end
  end

  def remove_favorite
    current_user.remove_favorite(sprite)

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
    end
  end

  private

  def sprite_params
    params[:sprite].permit(:description, :title, :width, :height, :parent_id, :editor, :replay_data, :file_base64_encoded, :image, :replay).merge(:user => current_user)
  end

  def collection
    return @collection if @collection

    items = Sprite

    if params[:order] == "recent"
      order = "id DESC"
      recency = 50.years.ago
    else
      order = "score DESC, id DESC"
      recency = 5.years.ago
    end

    if params[:tagged]
      items = items.tagged_with(params[:tagged])
    end

    items = items
      .order(order)
      .where(["sprites.created_at > '%s'", recency])
      .includes(:taggings)
      .search(params[:search])
      .page(params[:page])
      .per_page(per_page)

    @tag_counts = items.tag_counts_on(:tags).select do |t|
      t.taggings_count >= 5
    end

    logger.info @tag_counts

    @collection = items

    return @collection
  end

  def per_page
    if params[:per_page].blank?
      187
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
