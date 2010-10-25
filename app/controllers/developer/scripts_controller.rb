class Developer::ScriptsController < DeveloperController
  resource_controller
  actions :all, :except => [:destroy]

  before_filter :require_owner, :only => [:add_user]
  before_filter :require_access, :only => [:edit, :update]

  create.before do
    script.user = current_user
    script.script_type = "script"
  end

  create.wants.json do
    render :json => {
      :script => {
        :id => @script.id,
        :title => @script.title,
        :lang => @script.lang,
        :lib_id => @script.lib_id
      }
    }
  end

  def show
    
  end

  def load
    @script = Script.new(
      :parent => script,
      :title => script.title,
      :description => script.description,
      :code => script.code
    )
  end

  def add_user
    ScriptMember.create :script => script, :user => User.find(params[:user_id])

    flash[:notice] = "Added user id #{params[:user_id]} to script"

    redirect_to :back
  end

  private
  def script
    object
  end
  helper_method :script

  private
  def scripts
    collection
  end
  helper_method :scripts
end
