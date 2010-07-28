class Developer::LibrariesController < ResourceController::Base
  actions :all, :except => [:destroy]

  before_filter :require_user
  before_filter :require_owner, :only => [:edit, :update, :add_script]

  def add_script
    library.add_script(Script.find(params[:script_id]))
  end

  create.before do
    library.user = current_user
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
