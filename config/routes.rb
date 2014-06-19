PixieStrd6Com::Application.routes.draw do
  get "leads/create" => "leads#create"

  resources :projects do
    member do
      get :download
      get :fullscreen
      get :ide
      get :widget

      post :add_member
      post :fork
      post :save_file
      post :rename_file
      post :remove_file
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

      post :add_favorite
      post :remove_favorite

      post :add_tag
      post :remove_tag
    end

    collection do
      get :upload
      post :import
    end
  end

  resources :chats do
    collection do
      get :active_users
      get :recent
    end
  end

  resources :activities, :comments, :follows, :invites, :js_errors, :password_resets, :user_sessions

  match '/auth/:provider/callback', to: 'user_sessions#oauth'

  match 'begin' => "projects#info"
  match 'create-games' => "projects#info"

  match 'facebook' => "sprites#new", :as => :facebook

  match 'pixel-editor' => "sprites#new", :as => :new_sprite
  match 'arcade' => "projects#arcade"

  # Catch old urls
  match 'creation(/:dummy(/:dummy))' => "sprites#new"

  # Link Tracking
  match 'r/:token' => "links#track", :as => :link_token
  match 'i/:token' => "invites#track", :as => :invite_token

  match 'about' => "home#about", :as => :about
  match 'contact_us' => "home#contact", :as => :contact_us
  match 'jukebox' => "home#jukebox"
  match 'frost' => "home#frost", :as => :frost
  match 'privacy_policy' => "home#privacy_policy", :as => :privacy_policy
  match 'reports' => "home#reports"
  match 'sitemap' => "home#sitemap"
  match 'survey' => "home#survey", :as => :survey
  match 'wiki' => redirect('https://docs.google.com/document/d/1N_VbAu7hPmOQIL2XjLr0gTVfLL3W2qPWS3o1id4d-xI/edit?hl=en_US'), :as => :wiki

  match "login" => "user_sessions#new", :as => :sign_in
  match "logout" => "user_sessions#destroy", :as => :sign_out
  match 'authenticate' => 'user_sessions#create', :as => :authenticate, :via => :post
  match "sign_up" => "users#new", :as => :signup

  match 'users/remove_favorite/:id' => 'users#remove_favorite'

  # the people resource needs to go near the bottom because the
  # vanity urls will crush a bunch of other normal routes, such as login
  resources :people, :controller => :users, :as => :users, :except => :index, :path => '/' do
    resources :sprites

    member do
      get :edit
      get :recent_comments

      put :update

      post :add_to_collection
      post :set_avatar
    end

    collection do
      get :progress
      get :unsubscribe

      post :create
      post :install_plugin
      post :uninstall_plugin
      post :do_unsubscribe
    end

    # at the bottom so it doesn't crush the comments and sprites nested routes
    resources :projects, :except => :index, :path => '/' do
      member do
        get :debug
        get :download
        get :find_member_users
        get :fullscreen
        get :ide
        get :widget

        post :add_to_arcade
        post :add_member
        post :add_to_tutorial
        post :feature
        post :fork
        post :generate_docs
        post :remove_file
        post :remove_member
        post :rename_file
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
  end

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
