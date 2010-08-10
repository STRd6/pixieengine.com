class HomeController < ApplicationController
  def sitemap
    @sprite_pages_count = Sprite.count / Sprite.per_page
    @users = User.all(:select => "id, updated_at")
    @sprites = Sprite.all(:select => "id, title, updated_at", :limit => 10000)
  end
end
