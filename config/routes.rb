# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

# Defines the root path route ("/")
# root "articles#index"
Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get 'pages/about' => 'pages#about'
  get 'pages/search', to: 'pages#search', as: 'search'

  resources :products, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  resources :users, only: [:index, :show]
  resources :lists, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :referrals, only: [:index]
end
