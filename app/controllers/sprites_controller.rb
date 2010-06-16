class SpritesController < ResourceController::Base
  actions :all, :except => [:destroy]

  create.before do
    @sprite.user = current_user
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
