class ListingsController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @listings = Listing.includes(:user, images_attachments: :blob)
                       .search(@query)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(40)
  end
end
