EbayTest::Application.routes.draw do
  get "auth/new", to: "auth_callback#new"
  get "auth/bind", to: "auth_callback#create"

  resources :listings
end
