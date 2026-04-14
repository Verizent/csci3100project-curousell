class CancelOldPendingOrdersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Order.expired.includes(:listing).find_each { |order| order.cancel! }
  end
end
