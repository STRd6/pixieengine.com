class Developer::LibrariesController < DeveloperController
  resource_controller
  actions :all, :except => [:destroy]

  before_filter :require_user
  before_filter :require_owner, :only => [:edit, :update, :add_script, :remove_script]

  def add_script
    library.add_script(Script.find(params[:script_id]))

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html do
        flash[:notice] = "Script added"
        redirect_to :back
      end
    end
  end

  def remove_script
    library.remove_script(Script.find(params[:script_id]))

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html do
        flash[:notice] = "Script removed"
        redirect_to :back
      end
    end
  end

  def show
    
  end

  create.before do
    library.user = current_user

    unless params[:script_id].blank?
      library.library_scripts.build(:script_id => params[:script_id])
    end

    unless params[:app_id].blank?
      app = App.find params[:app_id]

      if app.has_access? current_user
        library.app_libraries.build(:app => app)
      end
    end
  end

  create.wants.json do
    render :json => {
      :status => "ok",
      :id => library.id,
      :title => library.title,
      :library => {
        :id => library.id,
        :scripts => [],
        :title => library.title,
      }
    }
  end

  private
  def library
    object
  end
  helper_method :library

  def libraries
    collection
  end
  helper_method :libraries
end
