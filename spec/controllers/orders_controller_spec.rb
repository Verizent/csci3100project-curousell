require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  let(:seller) { create(:user) }
  let(:buyer)  { create(:user) }
  let(:listing) { create(:listing, user: seller, status: "in_process") }
  let(:order)   { create(:order, listing: listing, buyer: buyer, status: "paid") }

  describe "GET #index" do
    it "redirects guests to sign in" do
      get :index
      expect(response).to redirect_to(account_signin_path)
    end

    it "loads buying and selling orders for authenticated users" do
      stub_current_user(buyer)
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:buying)).to be_a(ActiveRecord::Relation)
      expect(assigns(:selling)).to be_a(ActiveRecord::Relation)
    end
  end

  describe "POST #buyer_confirm" do
    it "redirects guests to sign in" do
      post :buyer_confirm, params: { id: order.id }
      expect(response).to redirect_to(account_signin_path)
    end

    it "confirms receipt for the buyer" do
      stub_current_user(buyer)
      post :buyer_confirm, params: { id: order.id }
      expect(order.reload.buyer_confirmed_at).to be_present
      expect(response).to redirect_to(order_path(order))
    end

    it "rejects if buyer is not the current user" do
      stub_current_user(seller)
      post :buyer_confirm, params: { id: order.id }
      expect(response).to redirect_to(orders_path)
    end

    it "rejects if order is not paid" do
      order.update!(status: "completed")
      stub_current_user(buyer)
      post :buyer_confirm, params: { id: order.id }
      expect(response).to redirect_to(order_path(order))
      expect(flash[:alert]).to be_present
    end
  end

  describe "POST #seller_confirm" do
    it "redirects guests to sign in" do
      post :seller_confirm, params: { id: order.id }
      expect(response).to redirect_to(account_signin_path)
    end

    it "confirms delivery for the seller" do
      stub_current_user(seller)
      post :seller_confirm, params: { id: order.id }
      expect(order.reload.seller_confirmed_at).to be_present
      expect(response).to redirect_to(order_path(order))
    end

    it "rejects if seller is not the current user" do
      stub_current_user(buyer)
      post :seller_confirm, params: { id: order.id }
      expect(response).to redirect_to(orders_path)
    end
  end
end
