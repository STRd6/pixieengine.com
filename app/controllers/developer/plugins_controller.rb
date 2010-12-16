class Developer::PluginsController < DeveloperController
  resource_controller
  actions :all, :except => [:destroy]

  before_filter :require_owner, :only => [:edit, :update]

  create.before do
    plugin.user = current_user
    plugin.plugin_type = "tool"
  end

  new_action.before do
    plugin.code = <<-eos
{
  name: "New Plugin",
  icon: "/images/icons/wrench.png",
  cursor: "url(/images/icons/wrench.png) 15 0, default",
  mousedown: function() {
    // TODO: Code your plugin here

    // Example: reading the color of the clicked pixel
    alert(this.color());

    // Example: Pixel has reference to canvas
    var canvas = this.canvas;
  }
}
    eos
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

  private
  def plugins
    collection
  end
  helper_method :plugins
end
