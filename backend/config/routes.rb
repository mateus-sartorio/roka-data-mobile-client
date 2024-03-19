Rails.application.routes.draw do
  resources :receipts
  resources :currency_handouts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :residents, only: [:index, :show, :create, :update, :destroy]
  resources :collects, only: [:index, :show, :create, :update, :destroy]
end