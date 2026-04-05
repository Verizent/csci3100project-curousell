class ListingsController < ApplicationController
  def index
    @query  = params[:q].to_s.strip
    @filter = params[:filter].to_s.strip
    college = current_user&.college

    @listings = Listing.includes(:user, images_attachments: :blob)
                       .search(@query)
                       .apply_filter(@filter, college)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(40)
  end
end
