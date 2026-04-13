class ListingsController < ApplicationController
  before_action :require_login, only: [ :edit, :update ]

  def index
    @query                = params[:q]
    @filter_categories    = Array(params[:categories]).select { |c| Listing::CATEGORIES.include?(c) }
    @filter_free          = params[:free] == "1"
    @filter_max_price     = params[:max_price].presence
    @filter_college       = params[:college] == "1"
    @filter_members_only  = params[:members_only] == "1"

    restricted_sql = "EXISTS (SELECT 1 FROM listing_access_rules WHERE listing_id = listings.id)"

    @listings = Listing.includes(:access_rules).search(@query).visible_to(current_user).where(status: "unsold")
    @listings = @listings.where(category: @filter_categories)                         if @filter_categories.any?
    @listings = @listings.where(price: 0)                                             if @filter_free
    @listings = @listings.where("price <= ?", @filter_max_price.to_i)                 if @filter_max_price
    @listings = @listings.where(location: current_user.college)                       if @filter_college && current_user
    @listings = @listings.where(restricted_sql)                                       if @filter_members_only
    @listings = @listings.order(Arel.sql("#{restricted_sql} DESC, listings.created_at DESC")).page(params[:page]).per(40)

    @show_members_only_filter = current_user.present? &&
      Listing.visible_to(current_user).where(restricted_sql).exists?
  end

  def show
    @listing = Listing.includes(:access_rules).find(params[:id])

    # Seller can always see their own listing
    return if @listing.user == current_user

    unless Listing.visible_to(current_user).exists?(@listing.id)
      redirect_to home_path, alert: "This listing is not available to you." and return
    end

    # Non-unsold listings are only visible to the buyer of the active order
    if @listing.status != "unsold"
      active_order = @listing.orders.find_by("status != ?", "cancelled")
      unless active_order&.buyer_id == current_user&.id
        redirect_to home_path, alert: "This listing is not available to you." and return
      end
    end
  end

  def new
    @listing = Listing.new
    @listing.access_rules.build
  end

  def edit
    @listing = Listing.find(params[:id])
    unless @listing.user == current_user
      redirect_to home_path, alert: "You can only edit your own listings." and return
    end
    if @listing.status != "unsold"
      redirect_to listing_path(@listing), alert: "This listing cannot be edited while a transaction is in progress or completed." and return
    end
  end

  def update
    @listing = Listing.find(params[:id])
    unless @listing.user == current_user
      redirect_to home_path, alert: "You can only edit your own listings." and return
    end
    if @listing.status != "unsold"
      redirect_to listing_path(@listing), alert: "This listing cannot be edited while a transaction is in progress or completed." and return
    end

    if @listing.update(listing_params)
      redirect_to @listing, notice: "Listing updated successfully."
    else
      render :edit
    end
  end

  private

  def listing_params
    params.require(:listing).permit(:title, :description, :price, :category, :location, images: [])
  end
end
