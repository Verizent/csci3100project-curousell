class AutoCancelOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return unless order
    return unless order.status == "paid"

    order.auto_cancel!
  end
end
