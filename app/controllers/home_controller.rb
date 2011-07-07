class HomeController < ApplicationController
  before_filter :hide_feedback

  def sitemap
    @sprite_pages_count = Sprite.count / Sprite.per_page
    @users = User.all(:select => "id, display_name, updated_at")
    @sprites = Sprite.select("id, title, updated_at").limit(1_000).order("id DESC")
  end

  def survey
    @hide_dock = true
  end

  def jukebox
  end
end
