class OrdersController < ApplicationController
  before_action :require_login

  def index
    Order.cancel_expired!
    @bought_orders = current_user.purchases.includes(:listing, :seller).order(created_at: :desc)
    @sold_orders = current_user.sales.includes(:listing, :buyer).order(created_at: :desc)
    @my_listings = Listing.where(user_id: current_user.id).includes({ images_attachments: :blob }, orders: :buyer).order(created_at: :desc)
  end

  def confirm
    order = Order.find(params[:id])

    unless [ order.buyer, order.seller ].include?(current_user)
      redirect_to orders_path, alert: "You are not authorized to confirm this order." and return
    end

    if order.seller == current_user
      if order.status != "pending"
        redirect_to orders_path, alert: "This order is no longer pending." and return
      end

      order.deliver!
      redirect_to orders_path, notice: "Delivery recorded. Waiting for buyer to confirm receipt."
    else
      if order.status != "delivered"
        redirect_to orders_path, alert: "This order is not ready to be marked as received." and return
      end

      order.receive!
      redirect_to orders_path, notice: "Receipt recorded."
    end
  end
end
