class Developer::ScriptsController < ResourceController::Base
  actions :all, :except => [:destroy]

  before_filter :require_owner, :only => [:edit, :update]

  create.before do
    script.user = current_user
    script.script_type = "script"
  end

  def load
    @script = Script.new(
      :parent => script,
      :title => script.title,
      :description => script.description,
      :code => script.code
    )
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
