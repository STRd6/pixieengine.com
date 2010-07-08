class HomeController < ApplicationController
  def index
    if ab_test("load_pic")
      redirect_to load_sprite_path(26)
    else
      redirect_to new_sprite_path
    end
  end
end
