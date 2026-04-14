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


## How to run the app on your local machine?
```bash
bundle install          # install the required dependencies
./bin/rails db:setup    # idempotent, set up admin user
./bin/dev               # run the rails server alongside the tailwindcss watcher
```
