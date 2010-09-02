class Developer::AppsController < DeveloperController
  resource_controller
  actions :all, :except => [:destroy]

  before_filter :require_user, :only => [:fork_post]
  before_filter :require_owner, :only => [:edit, :update, :add_library, :remove_library]

  create.before do
    app.user = current_user
  end

  def fork_post
    fork = App.create(
      :parent => app,
      :title => "#{app.title} (#{current_user.display_name}'s Fork)",
      :description => app.description,
      :html => app.html,
      :libraries => app.libraries,
      :code => app.code,
      :test => app.test,
      :user => current_user
    )

    redirect_to edit_developer_app_path(fork)
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

  def add_library
    app.add_library(Library.find(params[:library_id]))

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
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
end
