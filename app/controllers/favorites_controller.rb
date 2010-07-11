class FavoritesController < ResourceController::Base
  actions :all, :except => [:index, :show, :edit, :update]

  create.flash nil

  create.after do
    render :nothing => true
  end
end
