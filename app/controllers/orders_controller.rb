class OrdersController < ApplicationController
  before_action :require_login

  def index
    @bought_orders = current_user.purchases.includes(:listing, :seller).order(created_at: :desc)
    @sold_orders = current_user.sales.includes(:listing, :buyer).order(created_at: :desc)
  end

  def confirm
    order = Order.find(params[:id])
    if order.buyer == current_user
      order.buyer_confirm!
    elsif order.seller == current_user
      order.seller_confirm!
    else
      redirect_to orders_path, alert: "You are not authorized to confirm this order."
      return
    end
    redirect_to orders_path, notice: "Order confirmed successfully."
  end
end
