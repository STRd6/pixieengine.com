class Developer::AppsController < ResourceController::Base
  actions :all, :except => [:destroy]

  before_filter :require_owner, :only => [:edit, :update]

  create.before do
    app.user = current_user
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
