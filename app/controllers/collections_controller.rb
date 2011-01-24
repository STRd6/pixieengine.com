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

  def per_page
    if params[:per_page].blank?
      Collection.per_page
    else
      params[:per_page].to_i
    end
  end

  helper_method :collections
  def collections
    collection
  end

  helper_method :paged_collections
  def paged_collections
    collection.paginate(:page => params[:page], :per_page => per_page, :order => 'id DESC')
  end

  def user
    object.user
  end
  helper_method :user
end
