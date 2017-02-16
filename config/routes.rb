Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/mgmt', as: 'rails_admin'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  root :to => "sprites#new"

  get "login" => "user_sessions#new",
    :as => :sign_in
  get "logout" => "user_sessions#destroy",
    :as => :sign_out
  post "authenticate" => 'user_sessions#create',
    :as => :authenticate

  get 'survey' => "home#survey", :as => :survey
  get 'sitemap' => "home#sitemap"
  get 'unsubscribe/:signature' => "home#unsubscribe", :as => :unsubscribe

  get 'i/:token' => "invites#track", :as => :invite_token

  get 'pixel-editor' => "sprites#pixie", :as => :pixel_editor
  get 'collage' => "sprites#collage", :as => :collage_editor

  get 'chatframe' => 'static#chatframe'

  get 'chat' => 'chat#index', :as => :chat

  # Catch old urls
  get 'creation(/:dummy(/:dummy))' => "sprites#new"

  post 'admin/undeliverable' => "admin#undeliverable"
  post 'admin/bounced' => "admin#bounced"

  resources :comments, :follows, :invites, :password_resets

  resources :sprites do
    member do
      get :load

      post :add_favorite
      post :remove_favorite

      post :add_tag
      post :remove_tag

      patch :suppress
    end

    collection do
      get :new_editor
      get :upload
      post :import
    end
  end

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
  end

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
