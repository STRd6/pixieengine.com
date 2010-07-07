class SpritesController < ResourceController::Base
  actions :all, :except => [:destroy]

  create.before do
    @sprite.user = current_user
  end

  create.flash nil

  create.wants.js do
    render :update do |page|
      link = link_to "Sprite #{@sprite.id}", @sprite

      page.call "notify", "Saved as #{link}"
    end
  end

  new_action.wants.html do
    render :action => :pixie
  end

  def load
    @width = sprite.width
    @height = sprite.height
    @data = sprite.json_data

    render :action => :pixie
  end

  def load_url
    if params[:url].blank?
      # Render form
    else
      sprite = Sprite.data_from_url(params[:url])

      @width = sprite[:width]
      @height = sprite[:height]
      @data = sprite[:json_data]

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

  helper_method :sprites
  def sprites
    return collection
  end

  helper_method :sprite
  def sprite
    return object
  end
end
