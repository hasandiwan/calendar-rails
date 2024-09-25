# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :authentications do
    resources :events, only: :index
  end
  #root "home#index"
  get  "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get  "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  resources :sessions, only: [:index, :show, :destroy]
  resource  :password, only: [:edit, :update]
  namespace :identity do
    resource :email,              only: [:edit, :update]
    resource :email_verification, only: [:show, :create]
    resource :password_reset,     only: [:new, :edit, :create, :update]
  end
  get  "/auth/failure",            to: "sessions/omniauth#failure"
  get  "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "/auth/:provider/callback", to: "sessions/omniauth#create"
  namespace :sessions do
    resource :sudo, only: [:new, :create]
  end
  #root "home#index"
  resources :events
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post '/qr', to: 'events#qr'

  # Defines the root path route ("/")
  root 'events#index'
end
