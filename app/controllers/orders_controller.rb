class OrdersController < ApplicationController
  before_action :require_login

  def index
    @bought_orders = current_user.purchases.includes(:listing, :seller).order(created_at: :desc)
    @sold_orders = current_user.sales.includes(:listing, :buyer).order(created_at: :desc)
  end
end