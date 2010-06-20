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

  def load

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
