# frozen_string_literal: true

Rails.application.routes.draw do
  resources :events
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post '/qr', to: 'events#qr'

  # Defines the root path route ("/")
  root 'events#index'
end
