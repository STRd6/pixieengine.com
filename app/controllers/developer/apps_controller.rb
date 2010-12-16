class Developer::AppsController < DeveloperController
  resource_controller
  actions :all, :except => [:destroy]

  before_filter :require_user, :only => [:fork_post, :new, :create]
  before_filter :require_access, :only => [:edit, :update, :add_library, :remove_library]
  before_filter :require_owner, :only => [:add_user]

  respond_to :html, :xml, :json

  create.before do
    app.user = current_user
  end

  def create_app_sprite
    if has_access?
      app_sprite_data = params[:app_sprite]
      app_sprite_data[:sprite] = Sprite.new(app_sprite_data[:sprite].merge(:user => current_user))

      if params[:app_sprite_id]
        app_sprite = app.app_sprites.find params[:app_sprite_id]
      end

      if app_sprite
        app_sprite.update_attributes app_sprite_data
      else
        app_sprite = app.app_sprites.create app_sprite_data
      end

      respond_to do |format|
        format.json {render :json => app_sprite}
      end
    else
      render :json => {
        :status => "error",
        :message => "You do not have access to this app"
      }
    end
  end

  def fork_post
    fork = App.create(
      :parent => app,
      :title => "#{app.title} (#{current_user.display_name}'s Fork)",
      :description => app.description,
      :html => app.html,
      :libraries => app.libraries,
      :width => app.width,
      :height => app.height,
      :code => app.code,
      :test => app.test,
      :user => current_user
    )

    redirect_to edit_developer_app_path(fork)
  end

  def add_user
    AppMember.create :app => app, :user => User.find(params[:user_id])

    flash[:notice] = "Added user id #{params[:user_id]} to app"

    redirect_to :back
  end

  def ide
    render :layout => "ide"
  end

  def load
    @app = App.new(
      :parent => app,
      :title => app.title,
      :description => app.description,
      :html => app.html,
      :code => app.code,
      :test => app.test
    )
  end

  def mobile
    render :layout => "mobile"
  end

  def widget
    respond_to do |format|
      format.html {render :layout => "widget"}
      format.js {render :layout => nil}
    end
  end

  def add_library
    library = Library.find(params[:library_id])
    app.add_library(library)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok",
          :library => {
            :id => library.id,
            :scripts => library.scripts.map {|script| {:title => script.title, :id => script.id, :lang => script.lang, :code => script.code, :src => script.src} },
            :title => library.title
          }
        }
      end
      format.html do
        flash[:notice] = "Library added"
        redirect_to :back
      end
    end
  end

  def remove_library
    app.remove_library(Library.find(params[:library_id]))

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html do
        flash[:notice] = "Library removed"
        redirect_to :back
      end
    end
  end

  private
  def app
    object
  end
  helper_method :app

  private
  def apps
    collection
  end
  helper_method :apps

  def collection
    @collection ||= App.order("id DESC")
  end
end
