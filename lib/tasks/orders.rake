namespace :orders do
  desc "Cancel pending orders older than 2 weeks and restore their listings to available"
  task expire: :environment do
    expired = Order.expired.includes(:listing).to_a
    expired.each { |order| order.cancel! }
    puts "Cancelled #{expired.size} expired order(s)."
  end
end
