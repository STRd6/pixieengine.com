PixieStrd6Com::Application.routes.draw do |map|
  namespace :abingo do
    match "dashboard" => 'dashboard#index'
  end

  namespace :admin do
    resources :comments, :feedbacks, :sprites, :users
  end

  namespace :developer do
    resources :plugins do
      member do
        get :load
      end
    end

    resources :scripts do
      member do
        get :load
        get :run
      end
    end

    resources :libraries do
      member do
        post :add_script
      end
    end
  end

  resources :feedbacks do
    collection do
      get :thanks
    end
  end

  resources :collections

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

  resources :users do
    member do
      get :favorites
      post :add_to_collection
      get :sprites
    end

    collection do
      post :install_plugin
      post :uninstall_plugin
    end
  end

  resources :comments, :password_resets, :user_sessions

  # Catch old urls
  match 'creation(/:dummy(/:dummy))' => "sprites#new"

  # Link Tracking
  match 'r/:token' => "links#track", :as => :link_token

  match 'about' => "home#about", :as => :about
  match 'sitemap' => "home#sitemap"

  match "login" => "user_sessions#new", :as => :login
  match "logout" => "user_sessions#destroy", :as => :logout
  match 'authenticate' => 'user_sessions#create', :as => :authenticate, :via => :post
  match "sign_up" => "users#new", :as => :signup

  match 'users/remove_favorite/:id' => 'users#remove_favorite'

  root :to => "sprites#new"

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
