class OrdersController < ApplicationController
  before_action :require_login

  def show
    @order = Order.includes(:listing, :buyer, :seller).find(params[:id])

    unless participant?(@order)
      redirect_to orders_path, alert: "You are not authorized to view this order." and return
    end
  end

  def create
    listing = Listing.find(params[:listing_id])

    if listing.user_id == current_user.id
      redirect_to listing_path(listing), alert: "You cannot order your own listing." and return
    end

    if listing.status != "unsold"
      redirect_to listing_path(listing), alert: "This listing is no longer available." and return
    end

    Order.create!(
      listing: listing,
      seller: listing.user,
      buyer: current_user,
      status: "pending",
      purchased_at: Time.current
    )

    redirect_to orders_path, notice: "Order placed successfully."
  end

  def index
    Order.cancel_expired!
    @bought_orders = current_user.purchases.includes(:listing, :seller).order(created_at: :desc)
    @sold_orders = current_user.sales.includes(:listing, :buyer).order(created_at: :desc)
    @my_listings = Listing.where(user_id: current_user.id).includes({ images_attachments: :blob }, orders: :buyer).order(created_at: :desc)
  end

  def confirm
    order = Order.find(params[:id])

    unless participant?(order)
      redirect_to orders_path, alert: "You are not authorized to confirm this order." and return
    end

    if order.seller == current_user
      if order.status != "pending"
        redirect_to orders_path, alert: "This order is no longer pending." and return
      end

      order.deliver!
      redirect_to orders_path, notice: "Delivery recorded. Waiting for buyer to confirm receipt."
    else
      if order.status == "delivered"
        order.receive!
        redirect_to orders_path, notice: "Receipt recorded."
      else
        redirect_to orders_path, alert: "This order is not ready to be marked as received." and return
      end
    end
  end

  def cancel
    order = Order.find(params[:id])

    unless participant?(order)
      redirect_to orders_path, alert: "You are not authorized to cancel this order." and return
    end

    if order.status != "pending"
      redirect_to orders_path, alert: "Only pending orders can be cancelled." and return
    end

    order.cancel!
    redirect_to orders_path, notice: "Order cancelled."
  end

  private

  def participant?(order)
    [ order.buyer, order.seller ].include?(current_user)
  end
end
