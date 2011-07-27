PixieStrd6Com::Application.routes.draw do
  mount Forem::Engine, :at => "community"

  get "subscribe" => "subscriptions#subscribe", :as => :subscribe
  get "subscriptions/thanks"
  post "subscriptions/changed"

  get "register_subscribe" => "users#register_subscribe", :as => :register_subscribe

  resources :projects do
    member do
      get :debug
      get :download
      get :fullscreen
      get :ide
      get :widget

      post :add_to_arcade
      post :add_to_tutorial
      post :feature
      post :fork
      post :generate_docs
      post :remove_file
      post :save_file
      post :tag_version
      post :update_libs
    end

    collection do
      get :github_integration
      post :hook
      get :info
    end
  end

  resources :collections do
    member do
      post :add
      post :remove
    end
  end

  resources :sprites do
    member do
      get :load

      post :add_tag
      post :remove_tag
    end

    collection do
      get :upload
      post :import
    end
  end

  resources :people, :controller => :users, :as => :users do
    member do
      post :add_to_collection
      post :set_avatar
    end

    collection do
      get :progress
      get :unsubscribe

      post :install_plugin
      post :uninstall_plugin
      post :do_unsubscribe
    end
  end

  resources :chats do
    collection do
      get :active_users
      get :recent
    end
  end

  resources :animations, :comments, :password_resets, :tilemaps, :user_sessions
  resources :invites

  match 'begin' => "projects#info"

  match 'facebook' => "sprites#new", :as => :facebook

  match 'pixel-editor' => "sprites#new", :as => :new_sprite
  match 'arcade' => "projects#arcade"

  # Catch old urls
  match 'creation(/:dummy(/:dummy))' => "sprites#new"

  # Link Tracking
  match 'r/:token' => "links#track", :as => :link_token
  match 'i/:token' => "invites#track", :as => :invite_token

  match 'about' => "home#about", :as => :about
  match 'jukebox' => "home#jukebox"
  match 'sitemap' => "home#sitemap"
  match 'survey' => "home#survey", :as => :survey

  match "login" => "user_sessions#new", :as => :sign_in
  match "logout" => "user_sessions#destroy", :as => :sign_out
  match 'authenticate' => 'user_sessions#create', :as => :authenticate, :via => :post
  match "sign_up" => "users#new", :as => :signup

  match 'users/remove_favorite/:id' => 'users#remove_favorite'

  root :to => "projects#info"

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
