class TunesController < ApplicationController
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
    @tune = Tune.create! tune_params

    track_event('create_tune')

    respond_to do |format|
      format.html do
        if tune.creator
          redirect_to tune
        else
          session[:saved_tunes] ||= {}
          session[:saved_tunes][tune.id] = 0

          redirect_to sign_in_path
        end
      end
      format.json do
        if tune.creator
          render :json => {
            :tune => {
              :id => tune.id,
              :title => tune.title,
            }
          }
        else
          session[:saved_tunes] ||= {}
          session[:saved_tunes][tune.id] = 0

          render :json => { :redirect => sign_in_path }
        end
      end
    end
  end

  def new
    @tune = Tune.new

    render action: :editor
  end

  def suppress
   sprite.suppress!
   redirect_back fallback_location: sprites_path
  end

  def index
    respond_with(tunes) do |format|
      format.json { render :json }
    end
  end

  def show
  end

  def editor
  end

  def edit
  end

  def destroy
    tune.destroy
    flash[:notice] = "Tune has been deleted."
    respond_with(tune)
  end

  def update
    @tune = Tune.find(params[:id])

    @tune.update_attributes(tune_params)

    respond_with(@tune)
  end

  def add_tag
    tune.add_tag(params[:tag])
    tune.save!

    respond_to do |format|
      format.html { redirect_back_or_root }
      format.json { render :json => {:status => "ok"} }
    end
  end

  def remove_tag
    tune.remove_tag(params[:tag])
    tune.save!

    respond_to do |format|
      format.html { redirect_back_or_root }
      format.json { render :json => {:status => "ok"} }
    end
  end

  def add_favorite
    current_user.add_favorite(tune)

    respond_to do |format|
      format.html { redirect_back_or_root }
      format.json { render :json => {:status => "ok"} }
    end
  end

  def remove_favorite
    current_user.remove_favorite(tune)

    respond_to do |format|
      format.html { redirect_back_or_root }
      format.json { render :json => {:status => "ok"} }
    end
  end

  private

  def tune_params
    params[:tune].permit(
      :title,
      :description,
      :content,
      :parent_id,
      :editor
    ).merge(:creator => current_user)
  end

  helper_method :tunes
  def tunes
    return @tunes if @tunes

    items = Tune

    if params[:order] == "recent"
      order = "id DESC"
      recency = 50.years.ago
    else
      order = "score DESC, id DESC"
      recency = 5.years.ago
    end

    if params[:search]
      items = items.search(params[:search])
    end

    if params[:tagged]
      items = items.tagged_with(params[:tagged])
    end

    items = items
      .order(order)
      .where(["tunes.created_at > '%s'", recency])
      .includes(:taggings)
      .page(params[:page])
      .per_page(per_page)

    @tag_counts = items.tag_counts_on(:tags).select do |t|
      t.taggings_count >= 1
    end

    @tunes = items

    return @tunes
  end

  def per_page
    if params[:per_page].blank?
      60
    else
      params[:per_page].to_i.clamp(1, 1000)
    end
  end

  helper_method :tune
  def tune
    object
  end

  def object
    return @tune ||= Tune.find(params[:id])
  end

end
