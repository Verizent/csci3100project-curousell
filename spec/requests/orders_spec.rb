require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:seller)  { create(:user) }
  let(:buyer)   { create(:user) }
  let(:listing) { create(:listing, user: seller, status: "in_process") }
  let!(:order)  { create(:order, listing: listing, buyer: buyer, status: "paid") }

  describe "GET /orders" do
    it "requires authentication" do
      get orders_path
      expect(response).to redirect_to(account_signin_path)
    end

    it "shows buying and selling sections to logged-in users" do
      sign_in_as(buyer)
      get orders_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Buying")
      expect(response.body).to include("Selling")
    end
  end

  describe "GET /orders/:id" do
    it "requires authentication" do
      get order_path(order)
      expect(response).to redirect_to(account_signin_path)
    end

    it "allows buyer to view their order" do
      sign_in_as(buyer)
      get order_path(order)
      expect(response).to have_http_status(:ok)
    end

    it "allows seller to view the order" do
      sign_in_as(seller)
      get order_path(order)
      expect(response).to have_http_status(:ok)
    end

    it "prevents unrelated users from viewing" do
      stranger = create(:user)
      sign_in_as(stranger)
      get order_path(order)
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "POST /orders/:id/buyer_confirm" do
    it "allows buyer to confirm receipt" do
      sign_in_as(buyer)
      post buyer_confirm_order_path(order)
      expect(order.reload.buyer_confirmed_at).to be_present
      expect(response).to redirect_to(order_path(order))
    end

    it "rejects non-buyers" do
      sign_in_as(seller)
      post buyer_confirm_order_path(order)
      expect(response).to redirect_to(orders_path)
    end
  end

  describe "POST /orders/:id/seller_confirm" do
    it "allows seller to confirm delivery" do
      sign_in_as(seller)
      post seller_confirm_order_path(order)
      expect(order.reload.seller_confirmed_at).to be_present
      expect(response).to redirect_to(order_path(order))
    end

    it "rejects non-sellers" do
      sign_in_as(buyer)
      post seller_confirm_order_path(order)
      expect(response).to redirect_to(orders_path)
    end
  end

  describe "POST /orders/:id/cancel" do
    it "allows buyer to cancel a paid order" do
      allow(Stripe::Refund).to receive(:create)
      sign_in_as(buyer)
      post cancel_order_path(order)
      expect(order.reload.status).to eq("refunded")
      expect(response).to redirect_to(orders_path)
    end

    it "prevents unrelated users from cancelling" do
      stranger = create(:user)
      sign_in_as(stranger)
      post cancel_order_path(order)
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to be_present
      expect(order.reload.status).to eq("paid")
    end
  end
end
