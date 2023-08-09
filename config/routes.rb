# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

# Defines the root path route ("/")
# root "articles#index"
Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get 'pages/about' => 'pages#about', as: 'about'
  get 'pages/search', to: 'pages#search', as: 'search'
  get 'pages/beta', to: 'pages#beta', as: 'beta'
  get 'pages/test', to: 'pages#test', as: 'test'
  get 'pages/no_permission', to: 'pages#no_permission', as: 'no_permission'

  get '/search_or_manual_product_upload', to: 'products#search_or_manual_product_upload', as: 'search_or_manual_product_upload'
  post '/fetch_amazon_product', to: 'scrape_products#fetch_amazon_product', as: 'fetch_amazon_product'
  post '/fetch_shopify_product', to: 'scrape_products#fetch_shopify_product', as: 'fetch_shopify_product'
  post 'fetch_generic_product', to: 'scrape_products#fetch_product_from_generic_store', as: 'fetch_generic_product'
  post '/fetch_product', to: 'scrape_products#fetch_product', as: 'fetch_product'

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
  resources :referrals, only: [:index]
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
