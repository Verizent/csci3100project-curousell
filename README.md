# CUROUSELL

## What is Curousell?

## How to run the app on your local machine?
```bash
bundle install          # install the required dependencies
./bin/rails db:create   # (only on first run) install and setup postgresql on your local machine before hand
./bin/dev               # run the rails server alongside the tailwindcss watcher
```  
## Next steps
  1. Replace the dummy API keys in config/initializers/stripe.rb (or set ENV vars / Rails credentials)
  2. Run rails db:migrate to create the tables
  3. Set up a Stripe webhook endpoint pointing to /payments/webhook in your Stripe dashboard
