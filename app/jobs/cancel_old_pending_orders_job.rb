class CancelOldPendingOrdersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Order.pending.where("purchased_at < ?", 2.weeks.ago).find_each do |order|
      order.cancel!
    end
  end
end
