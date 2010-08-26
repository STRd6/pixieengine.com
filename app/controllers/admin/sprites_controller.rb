class Admin::SpritesController < AdminController
  resource_controller
  actions :only, :index

  private
  def collection
    @collection ||= Sprite.paginate(:page => params[:page], :per_page => Sprite.per_page, :order => 'id DESC')
  end

  def sprites
    collection
  end
  helper_method :sprites
end
