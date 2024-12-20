# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

# Defines the root path route ("/")
# root "articles#index"
Rails.application.routes.draw do
  devise_for :users
  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  if Rails.env.production?
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq', as: :sidekiq_admin
    end
  else
    mount Sidekiq::Web => '/sidekiq', as: :sidekiq_admin
  end
  root to: "pages#home"
  get 'pages/about' => 'pages#about', as: 'about'
  get 'pages/search', to: 'pages#search', as: 'search'
  get 'pages/creators', to: 'pages#creators', as: 'creators'
  get 'pages/beta', to: 'pages#beta', as: 'beta'
  get 'pages/test', to: 'pages#test', as: 'test'
  get 'pages/no_permission', to: 'pages#no_permission', as: 'no_permission'

  get '/search_or_manual_product_upload', to: 'products#search_or_manual_product_upload', as: 'search_or_manual_product_upload'
  get '/search_or_manual_app_upload', to: 'products#search_or_manual_app_upload', as: 'search_or_manual_app_upload'
  post '/fetch_amazon_product', to: 'scrape_products#fetch_amazon_product', as: 'fetch_amazon_product'
  post '/fetch_shopify_product', to: 'scrape_products#fetch_shopify_product', as: 'fetch_shopify_product'
  post 'fetch_generic_product', to: 'scrape_products#fetch_product_from_generic_store', as: 'fetch_generic_product'
  post '/fetch_product', to: 'scrape_products#fetch_product', as: 'fetch_product'
  post '/fetch_app_or_website', to: 'scrape_apps#fetch_app_or_website', as: 'fetch_app_or_website'

  get '/fetch_facts', to: 'products#fetch_facts', as: 'fetch_facts'


  get 'settings/logout_and_redirect', to: 'settings#logout_and_redirect', as: 'logout_and_redirect'


  resources :contacts, only: [:new, :create ]
  get '/contacts', to: 'contacts#new', as: 'contact'
  get 'contacts/sent'

  resources :products, only: [:index, :show, :new, :create, :edit, :update, :destroy] do

    get 'photos', on: :collection


    member do
      get :comments
    end

    resources :comments, only: [:create, :show] do
      member do
        get :replies, as: :comment_replies
      end
    end

    member do
      post :bookmark, to: 'bookmarks#bookmark'
      post :unbookmark, to: 'bookmarks#unbookmark'
    end


  end

  resources :bookmarks, only: [:index]
  resources :comments, only: [:destroy]
  resources :notifications, only: [:index] do
    collection do
      post :clear_all
    end
    member do
      patch :mark_as_read
    end
  end


  resources :users, only: [:index, :show] do
    member do
      post :follow
      post :unfollow
      post :remove_follower
      get :test
    end
    get :follows, on: :member
  end

  resources :lists, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :referrals, only: [:index, :show, :update]
  resources :settings, only: [:index] do
    collection do
      get :email_password
      patch :update_email_password
      get :profile
      patch :update_profile
      get :privacy
      patch :update_privacy
      get :about
      get :terms_and_conditions
      get :privacy_policy
      get :beta
    end
  end

end
