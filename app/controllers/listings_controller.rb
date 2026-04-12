class ListingsController < ApplicationController
  before_action :require_login, only: [ :new, :create ]

  def index
    @query             = params[:q]
    @filter_categories = Array(params[:categories]).select { |c| Listing::CATEGORIES.include?(c) }
    @filter_free       = params[:free] == "1"
    @filter_max_price  = params[:max_price].presence
    @filter_college    = params[:college] == "1"

    @listings = Listing.search(@query).visible_to(current_user)
    @listings = @listings.where.not(user: current_user)                                if current_user
    @listings = @listings.where(category: @filter_categories)                          if @filter_categories.any?
    @listings = @listings.where(price: 0)                                              if @filter_free
    @listings = @listings.where("price <= ?", @filter_max_price.to_i)                  if @filter_max_price
    @listings = @listings.joins(:user).where(users: { college: current_user.college }) if @filter_college && current_user
    @listings = @listings.order(created_at: :desc).page(params[:page]).per(40)
  end

  def show
    @listing = Listing.find(params[:id])
    unless @listing.user == current_user || Listing.visible_to(current_user).exists?(@listing.id)
      redirect_to root_path, alert: "This listing is not available to you."
    end
  end

  def new
    @listing = Listing.new
    @listing.access_rules.build
  end

  def create
    @listing = Listing.new(listing_params)
    @listing.user = current_user

    if @listing.save
      redirect_to @listing, notice: "Your listing is live!"     # redirect to /listings/:id
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def listing_params
    params.require(:listing).permit(
      :title, :description, :price, :negotiable, :location, :category, :image,
      access_rules_attributes: [ :id, :_destroy, { colleges: [], departments: [], faculties: [] } ] # _destroy is used to delete
    )
  end
end
