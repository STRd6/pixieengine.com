class HomeController < ApplicationController
  before_filter :hide_feedback
  layout "fullscreen"

  def sitemap
    @sprite_pages_count = Sprite.count / Sprite.per_page
    @users = User.all(:select => "id, display_name, updated_at")
    @sprites = Sprite.all(:select => "id, title, updated_at", :limit => 10000)
  end

  def survey
    @hide_dock = true
  end
end
