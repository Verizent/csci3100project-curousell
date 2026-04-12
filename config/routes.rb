Rails.application.routes.draw do
  root to: redirect("/home")

  get "/home" => "listings#index", as: :home
<<<<<<< Updated upstream
<<<<<<< HEAD
  get "/orders"  => "orders#index",  as: :orders
=======
>>>>>>> 1df9ea645d254d9b8ca0ef1e469ee1494a684064
=======
>>>>>>> Stashed changes
  resources :listings, only: [ :index, :show, :new, :create ]
  resources :feedback, only: [ :create ]

  # Placeholder nav routes (pages to be built later)
<<<<<<< HEAD
  get "/chats"   => "placeholder#chats",   as: :chats
<<<<<<< Updated upstream
=======
  get "/orders"  => "placeholder#orders",  as: :orders
>>>>>>> 1df9ea645d254d9b8ca0ef1e469ee1494a684064
=======
  get "/orders"  => "orders#index",  as: :orders
>>>>>>> Stashed changes
  get "/profile" => "placeholder#profile", as: :profile

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
