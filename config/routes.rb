Rails.application.routes.draw do
  root to: redirect("/home")

  get "/home" => "listings#index", as: :home
  resources :listings, only: [ :index, :show, :new, :create, :edit, :update ]
  resources :feedback, only: [ :create ]
  resources :orders, only: [ :index ] do
    member do
      post :confirm
    end
  end

  # Placeholder nav routes (pages to be built later)
  # get "/chats"   => "placeholder#chats",   as: :chats
  get "/profile" => "account#profile",     as: :profile

  # Chat routes
  resources :chats, only: [ :index, :show, :new ] do
    member do
      post :send_message
    end
  end

  # Authentication
  get  "/account/signup" => "account#signup",           as: :account_signup
  post "/account/signup" => "account#create_user"
  get  "/account/verify" => "account#verify",           as: :signup_verify
  post "/account/verify" => "account#verify_signup_otp"
  get  "/account/signin" => "account#signin",           as: :account_signin
  post "/account/signin" => "account#authenticate"
  get  "/account/2fa"    => "account#two_factor",       as: :signin_2fa
  post "/account/2fa"    => "account#verify_2fa"
  delete "/account/signout" => "account#signout",        as: :account_signout

  get "up" => "rails/health#show", as: :rails_health_check
  mount ActionCable.server => "/cable"
end
