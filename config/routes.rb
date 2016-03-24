EbayTest::Application.routes.draw do
  get "auth/new", to: "auth_callback#new"
  get "auth/bind", to: "auth_callback#create"

  resources :listings
  resources :notifications
  resource :setup do
    post "notifications", to: "setups#notifications"
  end
  resources :orders
end
