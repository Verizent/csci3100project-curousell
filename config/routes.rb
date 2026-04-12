Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  root "hello#index"
  get "up" => "rails/health#show", as: :rails_health_check
  get "/account/signup" => "account#signup", as: :account_signup
  post "/account/signup" => "account#create_user"
  get "/account/verify" => "account#verify", as: :signup_verify
  post "/account/verify" => "account#verify_signup_otp"
  get "/account/signin" => "account#signin", as: :account_signin
  post "/account/signin" => "account#authenticate"
  get "/account/2fa" => "account#two_factor", as: :signin_2fa
  post "/account/2fa" => "account#verify_2fa"

  # Payments
  post "/payments/checkout/:product_id" => "payments#checkout", as: :payment_checkout
  get  "/payments/success" => "payments#success", as: :payment_success
  get  "/payments/cancel" => "payments#cancel", as: :payment_cancel
  post "/payments/webhook" => "payments#webhook", as: :stripe_webhook

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
