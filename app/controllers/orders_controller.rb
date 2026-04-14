class OrdersController < ApplicationController
  before_action :require_login
  before_action :set_order, only: [ :show, :buyer_confirm, :seller_confirm ]

  def index
    @buying  = current_user.buyer_orders.includes(:listing).order(created_at: :desc)
    @selling = current_user.seller_orders.includes(:listing).order(created_at: :desc)
  end

  def show
  end

  def buyer_confirm
    unless @order.buyer == current_user
      redirect_to orders_path, alert: "Not authorised." and return
    end
    unless @order.status == "paid"
      redirect_to order_path(@order), alert: "Order is not awaiting confirmation." and return
    end

    @order.confirm_by_buyer!
    redirect_to order_path(@order), notice: "You have confirmed receipt. Waiting for the seller to confirm."
  end

  def seller_confirm
    unless @order.seller == current_user
      redirect_to orders_path, alert: "Not authorised." and return
    end
    unless @order.status == "paid"
      redirect_to order_path(@order), alert: "Order is not awaiting confirmation." and return
    end

    @order.confirm_by_seller!
    redirect_to order_path(@order), notice: "You have confirmed delivery. Waiting for the buyer to confirm."
  end

  private

  def set_order
    @order = Order.includes(:listing).find(params[:id])
    unless @order.buyer == current_user || @order.seller == current_user
      redirect_to orders_path, alert: "Not authorised." and return
    end
  end
end
