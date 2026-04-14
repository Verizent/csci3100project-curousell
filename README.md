# CUROUSELL

## What is Curousell?

Curousell is a centralized web platform designed to optimize the way CUHK community 
members buy, sell, and donate second-hand items. Items can be searched by category (textbooks, 
furniture, electronics) for users’ convenience. Users can also chat about the item with the seller. Some constraints are imposed, such as some items can be purchased only for specific college members. 

Distribution of work: 
| Feature Name           | Primary Developer                | Secondary Developer    | Notes 
| :---                   |     :---:                        |          :---:         | ---:
| login/authentication   | Michael Richard Suryajaya        | Po Chi Hang            | Gmail SMTP
| main page              | Kent Justin Henly                | x                      | Fuzzy Search 
| chat feature           | Asset Yermukhanbet               | x                      | ActionCable 
| payment feature        | Po Chi Hang                      | Kanta Fujimoto         | Stripe 
| user's orders page     | Kanta Fujimoto                   | Po Chi Hang            | Hotwire Stimulus
| add/edit item          | Michael Richard Suryajaya        | Kanta Fujimoto         | Google Maps API 

## Setup your own `config/credentials.yml.enc` for local testing
```yml
# Gmail SMTP Configuration
gmail:
  username: <your-gmail-account>
  password: <your-app-password>

google_maps_api_key: <your-gmap-apikey> # enable Maps Embed API, Maps JavaScript API, Places API

stripe:
  secret_key: <stripe-secret-key>
  publishable_key: <stripe-publishable-key>
  webhook_secret: <stripe-webhook-secret>
```

## How to run the app on your local machine?
```bash
bundle install          # install the required dependencies
./bin/rails db:setup    # create and seed database
./bin/dev               # run the rails server alongside the tailwindcss watcher
```  

## Next steps
  1. Replace the dummy API keys in config/initializers/stripe.rb (or set ENV vars / Rails credentials)
  2. Run rails db:migrate to create the tables
  3. Set up a Stripe webhook endpoint pointing to /payments/webhook in your Stripe dashboard

## SimpleCov Report
<img src="./SimpleCov Report.png" />
