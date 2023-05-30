# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

# Defines the root path route ("/")
# root "articles#index"
Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get 'pages/about' => 'pages#about'
  get 'pages/search', to: 'pages#search', as: 'search'

  resources :products, only: [:index, :show, :new, :create, :edit, :update, :destroy] do

    member do
      get :comments
    end

    resources :comments, only: [:create, :show] do
      member do
        get :replies, as: :comment_replies
      end
    end

  end

  resources :comments, only: [:destroy]

  resources :users, only: [:index, :show] do
    member do
      post :follow
      post :unfollow
      post :remove_follower
    end
    get :follows, on: :member
  end

  resources :lists, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :referrals, only: [:index]
end
