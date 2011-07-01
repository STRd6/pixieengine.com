class CollectionsController < ApplicationController
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

  def create
    @collection = Collection.new params[:collection]
    @collection.user = current_user

    if params[:sprite_id]
      @collection.collection_items.build(:item => Sprite.find(params[:sprite_id]))
    end

    @collection.save

    respond_to do |format|
      format.json do
        render :json => {:status => "ok", :id => @collection.id, :title => @collection.title}
      end
    end
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

  def object
    @collection ||= Collection.find params[:id]
  end

  def user
    object.user
  end
  helper_method :user
end
