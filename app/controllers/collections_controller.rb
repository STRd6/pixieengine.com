class CollectionsController < ResourceController::Base
  actions :all, :except => [:edit, :update, :destroy]

  before_filter :require_owner, :only => [:add, :remove]

  def add
    object.add(Sprite.find(params[:sprite_id]))

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html do
        flash[:notice] = "Item added"
        redirect_to :back
      end
    end
  end

  def remove
    object.remove(Sprite.find(params[:sprite_id]))

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html do
        flash[:notice] = "Item removed"
        redirect_to :back
      end
    end
  end

  create.before do
    object.user = current_user

    if params[:sprite_id]
      object.collection_items.build(:item => Sprite.find(params[:sprite_id]))
    end
  end

  create.wants.json do
    render :json => {:status => "ok", :id => object.id, :title => object.title}
  end

  private

  helper_method :collections
  def collections
    collection
  end

  def user
    object.user
  end
  helper_method :user
end
