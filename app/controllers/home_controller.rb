class HomeController < ApplicationController
  def index
    if ab_test("load_pic")
      redirect_to load_sprite_path(26)
    else
      redirect_to new_sprite_path
    end
  end

  def sitemap
    @sprite_pages_count = Sprite.count / Sprite.per_page
    @users = User.all(:select => "id, updated_at")
    @sprites = Sprite.all(:select => "id, updated_at", :limit => 10000)
  end
end
