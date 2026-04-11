class ListingsController < ApplicationController
  def index
    @query             = params[:q]
    @filter_categories = Array(params[:categories]).select { |c| Listing::CATEGORIES.include?(c) }
    @filter_free       = params[:free] == "1"
    @filter_max_price  = params[:max_price].presence
    @filter_college    = params[:college] == "1"

    @listings = Listing.search(@query).visible_to(current_user)
    @listings = @listings.where(category: @filter_categories)                          if @filter_categories.any?
    @listings = @listings.where(price: 0)                                              if @filter_free
    @listings = @listings.where("price <= ?", @filter_max_price.to_i)                 if @filter_max_price
    @listings = @listings.joins(:user).where(users: { college: current_user.college }) if @filter_college && current_user
    @listings = @listings.order(Arel.sql("EXISTS (SELECT 1 FROM listing_access_rules WHERE listing_id = listings.id) DESC, listings.created_at DESC")).page(params[:page]).per(40)
  end

  def show
    @listing = Listing.find(params[:id])
    unless Listing.visible_to(current_user).exists?(@listing.id)
      redirect_to root_path, alert: "This listing is not available to you."
    end
  end
end
