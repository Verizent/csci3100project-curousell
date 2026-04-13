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

    if order.status != "pending"
      redirect_to orders_path, alert: "This order is no longer pending." and return
    end

    if order.confirmed_by?(current_user)
      redirect_to orders_path, alert: "You have already confirmed this order." and return
    end

    if order.buyer == current_user
      order.buyer_confirm!
    elsif order.seller == current_user
      order.seller_confirm!
    else
      redirect_to orders_path, alert: "You are not authorized to confirm this order." and return
    end

    if order.reload.status == "completed"
      redirect_to orders_path, notice: "Transaction complete! Both parties have confirmed."
    else
      redirect_to orders_path, notice: "Confirmation recorded. Waiting for the other party."
    end
  end
end
