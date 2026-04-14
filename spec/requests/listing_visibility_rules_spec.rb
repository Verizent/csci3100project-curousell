require "rails_helper"

RSpec.describe "ListingVisibilityRules", type: :request do
  let(:seller) { create(:user) }
  let(:viewer) { create(:user) }

  before do
    sign_in_as(viewer)
  end

  it "shows unsold listings on main page" do
    listing = create(:listing, user: seller, status: "unsold", title: "Visible Unsold")

    get home_path

    expect(response.body).to include(listing.title)
  end

  it "does not show sold listings on main page" do
    listing = create(:listing, user: seller, status: "sold", title: "Hidden Sold")

    get home_path

    expect(response.body).not_to include(listing.title)
  end

  it "does not show in_process listings on main page" do
    listing = create(:listing, user: seller, status: "in_process", title: "Hidden In Process")

    get home_path

    expect(response.body).not_to include(listing.title)
  end

  it "shows listing again after cancellation resets status to unsold" do
    listing = create(:listing, user: seller, status: "unsold", title: "Reappears After Cancel")
    order = create(:order, listing: listing, seller: seller, buyer: viewer, status: "pending")

    order.cancel!

    get home_path

    expect(listing.reload.status).to eq("unsold")
    expect(response.body).to include("Reappears After Cancel")
  end

  it "does not show user's own listing on main page" do
    own = create(:listing, user: viewer, status: "unsold", title: "My Own Listing")

    get home_path

    expect(response.body).not_to include(own.title)
  end
end
