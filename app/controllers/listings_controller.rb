class ListingsController < ApplicationController
<<<<<<< HEAD
  before_action :require_login, only: [ :new, :create ]

=======
>>>>>>> 0d3d52e20be76d8ca17664397d339a678223cbe1
  def index
    @query             = params[:q]
    @filter_categories = Array(params[:categories]).select { |c| Listing::CATEGORIES.include?(c) }
    @filter_free       = params[:free] == "1"
    @filter_max_price  = params[:max_price].presence
    @filter_college    = params[:college] == "1"

    @listings = Listing.search(@query).visible_to(current_user)
<<<<<<< HEAD
    @listings = @listings.where.not(user: current_user)                                if current_user
    @listings = @listings.where(category: @filter_categories)                          if @filter_categories.any?
    @listings = @listings.where(price: 0)                                              if @filter_free
    @listings = @listings.where("price <= ?", @filter_max_price.to_i)                  if @filter_max_price
    @listings = @listings.joins(:user).where(users: { college: current_user.college }) if @filter_college && current_user
    @listings = @listings.order(created_at: :desc).page(params[:page]).per(40)
=======
    @listings = @listings.where(category: @filter_categories)                          if @filter_categories.any?
    @listings = @listings.where(price: 0)                                              if @filter_free
    @listings = @listings.where("price <= ?", @filter_max_price.to_i)                 if @filter_max_price
    @listings = @listings.joins(:user).where(users: { college: current_user.college }) if @filter_college && current_user
    @listings = @listings.order(Arel.sql("EXISTS (SELECT 1 FROM listing_access_rules WHERE listing_id = listings.id) DESC, listings.created_at DESC")).page(params[:page]).per(40)
>>>>>>> 0d3d52e20be76d8ca17664397d339a678223cbe1
  end

  def show
    @listing = Listing.find(params[:id])
    unless Listing.visible_to(current_user).exists?(@listing.id)
      redirect_to root_path, alert: "This listing is not available to you."
    end
  end
<<<<<<< HEAD

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
      :title, :description, :price, :location, :category, :image,
      access_rules_attributes: [ :id, :_destroy, { colleges: [], departments: [], faculties: [] } ] # _destroy is used to delete
    )
  end
=======
>>>>>>> 0d3d52e20be76d8ca17664397d339a678223cbe1
end
