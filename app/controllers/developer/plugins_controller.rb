class Developer::PluginsController < ResourceController::Base
  actions :all, :except => [:destroy]

  before_filter :require_owner, :only => [:edit, :update]

  create.before do
    plugin.user = current_user
    plugin.plugin_type = "tool"
  end

  def load
    @plugin = Plugin.new(
      :parent => plugin,
      :title => plugin.title,
      :description => plugin.description,
      :code => plugin.code
    )
  end

  private
  def plugin
    object
  end
  helper_method :plugin
end
