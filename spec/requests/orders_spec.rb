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
    before do
      order.define_singleton_method(:confirmed_by?) do |user|
        user.id == buyer_id ? buyer_confirmed_at.present? : seller_confirmed_at.present?
      end
    end

    it "allows seller to mark as delivered (seller confirmation stage)" do
      sign_in_as(seller)

      expect {
        post confirm_order_path(order)
      }.to change { order.reload.seller_confirmed_at }.from(nil)

      expect(response).to redirect_to(orders_path)
    end

    it "does not allow unrelated users to confirm" do
      stranger = create(:user)
      sign_in_as(stranger)

      post confirm_order_path(order)

      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/not authorized/i)
    end

    it "completes order when buyer confirms after seller" do
      order.update!(seller_confirmed_at: Time.current)
      sign_in_as(buyer)

      post confirm_order_path(order)

      expect(order.reload.status).to eq("completed")
      expect(order.listing.reload.status).to eq("sold")
      expect(response).to redirect_to(orders_path)
    end

    it "rejects confirming non-pending orders" do
      order.update!(status: "cancelled")
      sign_in_as(seller)

      post confirm_order_path(order)

      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/no longer pending/i)
    end
  end

  describe "planned authorization endpoints" do
    it "prevents viewing order details when user is neither buyer nor seller" do
      skip("Not implemented: orders#show route/controller action does not exist yet")
    end

    it "prevents cancelling someone else's order" do
      skip("Not implemented: manual order cancellation endpoint does not exist yet")
    end

    it "protects admin-only order management endpoints" do
      skip("Not implemented: no admin-only order endpoints are currently defined in routes")
    end

    it "prevents buyers from ordering their own listing" do
      skip("Not implemented: order creation endpoint/service is not present yet")
    end

    it "prevents ordering sold or in_process listings" do
      skip("Not implemented: order creation endpoint/service is not present yet")
    end
  end
end
