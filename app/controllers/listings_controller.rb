class ListingsController < ApplicationController
  def index
    user_college = current_user&.college
    @query       = params[:q]
    @filter_category  = params[:category].presence
    @filter_college   = params[:college].presence
    @filter_free      = params[:free] == "1"
    @filter_max_price = params[:max_price].presence

    @listings = Listing.search(@query).visible_to(user_college)
    @listings = @listings.where(category: @filter_category) if @filter_category
    @listings = @listings.where(college: @filter_college)   if @filter_college
    @listings = @listings.where(price: 0)                  if @filter_free
    @listings = @listings.where("price <= ?", @filter_max_price.to_i) if @filter_max_price
    @listings = @listings.order(created_at: :desc).page(params[:page]).per(40)
  end

  def show
    @listing = Listing.find(params[:id])
  end
end
