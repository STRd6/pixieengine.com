PixieStrd6Com::Application.routes.draw do |map|
  namespace :abingo do
    match "dashboard" => 'dashboard#index'
  end

  resources :feedbacks do
    collection do
      get :thanks
    end
  end

  resources :sprites do
    member do
      get :load
    end

    collection do
      get :load_url
      get :upload
      post :import
    end
  end
  resources :users, :user_sessions

  resources :favorites

  # Catch old urls
  match 'creation(/:dummy(/:dummy))' => "sprites#new"

  # Link Tracking
  match 'r/:token' => "links#track"

  match 'about' => "home#about", :as => :about

  match "login" => "user_sessions#new", :as => :login
  match "logout" => "user_sessions#destroy", :as => :logout
  match 'authenticate' => 'user_sessions#create', :as => :authenticate, :via => :post
  match "sign_up" => "users#new", :as => :signup

  match 'users/remove_favorite/:id' => 'users#remove_favorite'

  root :to => "home#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
