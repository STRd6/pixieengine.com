PixieStrd6Com::Application.routes.draw do |map|
  namespace :abingo do
    match "dashboard" => 'dashboard#index'
  end

  namespace :admin do
    resources :comments, :feedbacks, :sprites, :users
  end

  namespace :developer do
    resources :apps do
      member do
        post :add_library
        post :add_user
        post :remove_library
        post :create_app_sprite
        post :set_app_data
        post :fork_post

        get :docs
        get :edit_code
        get :fork
        get :load
        get :run
        get :mobile
        get :widget
        get :lib, :defaults => { :format => 'js' }
        get :ide
        get :permissions
      end
    end

    resources :plugins do
      member do
        get :load
      end
    end

    resources :scripts do
      member do
        post :add_user

        get :load
        get :permissions
        get :run
        get :test
      end
    end

    resources :libraries do
      member do
        post :add_script
        post :remove_script

        get :test
      end
    end
  end

  resources :feedbacks do
    collection do
      get :thanks
    end
  end

  resources :collections do
    member do
      post :add
      post :remove
    end
  end

  resources :sounds do
    member do
      get :load
    end
  end

  resources :sprites do
    member do
      get :load

      post :add_tag
      post :remove_tag
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
      post :set_avatar
      get :sprites
    end

    collection do
      get :progress
      get :unsubscribe

      post :install_plugin
      post :uninstall_plugin
      post :do_unsubscribe
    end
  end

  resources :comments, :password_resets, :user_sessions
  resources :invites

  match 'pixel-editor' => "sprites#new", :as => :new_sprite
  match 'sfx-editor' => "sounds#new", :as => :new_sound

  # Catch old urls
  match 'creation(/:dummy(/:dummy))' => "sprites#new"

  # Link Tracking
  match 'r/:token' => "links#track", :as => :link_token
  match 'i/:token' => "invites#track", :as => :invite_token

  match 'about' => "home#about", :as => :about
  match 'sitemap' => "home#sitemap"
  match 'survey' => "home#survey", :as => :survey

  match "login" => "user_sessions#new", :as => :login
  match "logout" => "user_sessions#destroy", :as => :logout
  match 'authenticate' => 'user_sessions#create', :as => :authenticate, :via => :post
  match "sign_up" => "users#new", :as => :signup

  match "chat" => "chats#publish"
  match "active_users" => "chats#active_users"

  match 'users/remove_favorite/:id' => 'users#remove_favorite'
  match 'users/:id/progress' => 'users#progress'

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
