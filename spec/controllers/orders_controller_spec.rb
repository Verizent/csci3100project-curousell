require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let(:stranger) { create(:user) }

  describe "GET #index" do
    it "redirects guests to sign in" do
      get :index

      expect(response).to redirect_to(account_signin_path)
    end

    it "loads bought/sold listings for authenticated users" do
      stub_current_user(buyer)
      allow(Order).to receive(:cancel_expired!)

      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:bought_orders)).to be_a(ActiveRecord::Relation)
      expect(assigns(:sold_orders)).to be_a(ActiveRecord::Relation)
      expect(assigns(:my_listings)).to be_a(ActiveRecord::Relation)
    end
  end

  describe "POST #confirm" do
    let(:order) do
      instance_double(
        Order,
        id: 123,
        status: "pending",
        buyer: buyer,
        seller: seller
      )
    end

    before do
      allow(Order).to receive(:find).with(order.id.to_s).and_return(order)
      allow(order).to receive(:deliver!)
      allow(order).to receive(:receive!)
    end

    it "allows seller to record delivery confirmation" do
      stub_current_user(seller)

      post :confirm, params: { id: order.id }

      expect(order).to have_received(:deliver!)
      expect(response).to redirect_to(orders_path)
      expect(flash[:notice]).to match(/Delivery recorded/i)
    end

    it "allows buyer to record receipt confirmation" do
      stub_current_user(buyer)
      allow(order).to receive(:status).and_return("delivered")

      post :confirm, params: { id: order.id }

      expect(order).to have_received(:receive!)
      expect(response).to redirect_to(orders_path)
    end

    it "rejects users not part of the order" do
      stub_current_user(stranger)

      post :confirm, params: { id: order.id }

      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/not authorized/i)
    end

    it "rejects non-pending orders" do
      stub_current_user(seller)
      allow(order).to receive(:status).and_return("completed")

      post :confirm, params: { id: order.id }

      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to match(/no longer pending/i)
    end
  end
end
