class ListingsController < ApplicationController
  def index
    @listings = Listing.includes(:user, images_attachments: :blob)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(40)
  end
end
