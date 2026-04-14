require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let(:listing) { create(:listing, user: seller, status: "unsold") }
  let!(:order) { create(:order, listing: listing, seller: seller, buyer: buyer, status: "pending") }

  before do
    allow(Order).to receive(:cancel_expired!)
  end

  describe "GET /orders" do
    it "requires authentication" do
      get orders_path
      expect(response).to redirect_to(account_signin_path)
    end

    it "shows bought and sold sections to logged in users" do
      sign_in_as(buyer)

      get orders_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Items I\'ve Bought")
      expect(response.body).to include("My Listings")
    end

    it "includes pending/cancelled/completed statuses in all-items views" do
      create(:order, :cancelled, listing: create(:listing, user: seller), seller: seller, buyer: buyer)
      create(:order, :completed, listing: create(:listing, user: seller), seller: seller, buyer: buyer)

      sign_in_as(buyer)
      get orders_path

      expect(response.body).to include("Pending")
      expect(response.body).to include("Cancelled")
      expect(response.body).to include("Completed")
    end
  end

  describe "POST /orders/:id/confirm" do
    it "allows seller to mark as delivered (seller confirmation stage)" do
      sign_in_as(seller)

      expect {
        post confirm_order_path(order)
      }.to change { order.reload.status }.from("pending").to("delivered")

      expect(order.reload.seller_confirmed_at).to be_present

      expect(response).to redirect_to(orders_path)
    end

    it "does not allow unrelated users to confirm" do
      stranger = create(:user)
      sign_in_as(stranger)

      post confirm_order_path(order)

      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/not authorized/i)
    end

    it "marks order as received when buyer confirms after seller delivery" do
      order.deliver!
      sign_in_as(buyer)

      post confirm_order_path(order)

      expect(order.reload.status).to eq("received")
      expect(order.buyer_confirmed_at).to be_present
      expect(order.listing.reload.status).to eq("in_process")
      expect(response).to redirect_to(orders_path)
    end

    it "rejects confirming non-pending orders" do
      order.update!(status: "cancelled")
      sign_in_as(seller)

      post confirm_order_path(order)

      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/no longer pending/i)
    end

    it "rejects buyer confirmation before seller delivery" do
      sign_in_as(buyer)

      post confirm_order_path(order)

      expect(order.reload.status).to eq("pending")
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/not ready to be marked as received/i)
    end
  end

  describe "planned authorization endpoints" do
    it "prevents viewing order details when user is neither buyer nor seller" do
      stranger = create(:user)
      sign_in_as(stranger)

      get order_path(order)

      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/not authorized/i)
    end

    it "prevents cancelling someone else's order" do
      stranger = create(:user)
      sign_in_as(stranger)

      post cancel_order_path(order)

      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/not authorized/i)
      expect(order.reload.status).to eq("pending")
    end

    it "prevents buyers from ordering their own listing" do
      own_listing = create(:listing, user: buyer, status: "unsold")
      sign_in_as(buyer)

      expect {
        post orders_path, params: { listing_id: own_listing.id }
      }.not_to change(Order, :count)

      expect(response).to redirect_to(listing_path(own_listing))
      expect(flash[:alert]).to match(/cannot order your own listing/i)
    end

    it "prevents ordering sold or in_process listings" do
      sign_in_as(buyer)
      sold_listing = create(:listing, user: seller, status: "sold")
      in_process_listing = create(:listing, user: seller, status: "in_process")

      expect {
        post orders_path, params: { listing_id: sold_listing.id }
      }.not_to change(Order, :count)
      expect(response).to redirect_to(listing_path(sold_listing))
      expect(flash[:alert]).to match(/no longer available/i)

      expect {
        post orders_path, params: { listing_id: in_process_listing.id }
      }.not_to change(Order, :count)
      expect(response).to redirect_to(listing_path(in_process_listing))
      expect(flash[:alert]).to match(/no longer available/i)
    end
  end
end
