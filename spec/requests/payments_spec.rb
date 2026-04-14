require "rails_helper"
require "ostruct"

RSpec.describe "Payments", type: :request do
  let(:seller) { create(:user) }
  let(:buyer)  { create(:user) }
  let(:listing) { create(:listing, user: seller, status: "unsold", price: 120) }

  describe "POST /payments/checkout/:listing_id" do
    it "redirects guests to sign in" do
      post payment_checkout_path(listing)
      expect(response).to redirect_to(account_signin_path)
    end

    it "prevents buying your own listing" do
      sign_in_as(seller)

      post payment_checkout_path(listing)

      expect(response).to redirect_to(listing_path(listing))
      expect(Order.count).to eq(0)
    end

    it "creates order and redirects to Stripe Checkout for a valid buyer" do
      sign_in_as(buyer)
      stripe_session = instance_double("Stripe::Checkout::Session", id: "cs_test_123", url: "https://checkout.stripe.test/session")
      allow(Stripe::Checkout::Session).to receive(:create).and_return(stripe_session)

      post payment_checkout_path(listing)

      expect(response).to redirect_to("https://checkout.stripe.test/session")
      order = Order.last
      expect(order.buyer).to eq(buyer)
      expect(order.listing).to eq(listing)
      expect(order.status).to eq("pending")
      expect(order.stripe_checkout_session_id).to eq("cs_test_123")
      expect(listing.reload.status).to eq("in_process")
    end

    it "marks order failed and restores listing when Stripe fails" do
      sign_in_as(buyer)
      allow(Stripe::Checkout::Session).to receive(:create).and_raise(Stripe::StripeError.new("Stripe unavailable"))

      post payment_checkout_path(listing)

      expect(response).to redirect_to(listing_path(listing))
      expect(Order.last.status).to eq("failed")
      expect(listing.reload.status).to eq("unsold")
    end
  end

  describe "GET /payments/success" do
    it "renders success for buyer's own order" do
      sign_in_as(buyer)
      order = create(:order, buyer: buyer, listing: listing, status: "pending")

      get payment_success_path(order_id: order.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(order.listing.title)
    end

    it "redirects when order is not found for current user" do
      sign_in_as(buyer)
      other_order = create(:order, buyer: create(:user), listing: listing)

      get payment_success_path(order_id: other_order.id)

      expect(response).to redirect_to(home_path)
    end
  end

  describe "GET /payments/cancel" do
    it "cancels pending order and restores listing" do
      sign_in_as(buyer)
      in_process_listing = create(:listing, user: seller, status: "in_process")
      order = create(:order, buyer: buyer, listing: in_process_listing, status: "pending")

      get payment_cancel_path(order_id: order.id)

      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("cancelled")
      expect(in_process_listing.reload.status).to eq("unsold")
    end

    it "does not change non-pending order" do
      sign_in_as(buyer)
      paid_order = create(:order, :paid, buyer: buyer, listing: create(:listing, user: seller, status: "in_process"))

      get payment_cancel_path(order_id: paid_order.id)

      expect(paid_order.reload.status).to eq("paid")
    end

    it "redirects when order does not belong to current user" do
      sign_in_as(buyer)
      other_order = create(:order, buyer: create(:user), listing: listing)

      get payment_cancel_path(order_id: other_order.id)

      expect(response).to redirect_to(home_path)
    end
  end

  describe "POST /payments/webhook" do
    let(:headers) { { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "sig_test" } }

    it "returns bad_request for invalid JSON payload" do
      allow(Stripe::Webhook).to receive(:construct_event).and_raise(JSON::ParserError.new("invalid"))

      post stripe_webhook_path, params: "{bad-json", headers: headers

      expect(response).to have_http_status(:bad_request)
    end

    it "returns bad_request for invalid signature" do
      error = Stripe::SignatureVerificationError.new("bad signature", "sig_test")
      allow(Stripe::Webhook).to receive(:construct_event).and_raise(error)

      post stripe_webhook_path, params: "{}", headers: headers

      expect(response).to have_http_status(:bad_request)
    end

    it "marks matching order as paid when checkout session completes" do
      order = create(:order, listing: create(:listing, user: seller, status: "in_process"), status: "pending", stripe_checkout_session_id: "cs_complete")
      checkout_session = OpenStruct.new(id: "cs_complete", payment_intent: "pi_success")
      event = OpenStruct.new(type: "checkout.session.completed", data: OpenStruct.new(object: checkout_session))
      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post stripe_webhook_path, params: "{}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("paid")
      expect(order.stripe_payment_intent_id).to eq("pi_success")
    end

    it "marks matching order as failed when payment intent fails" do
      in_process_listing = create(:listing, user: seller, status: "in_process")
      order = create(:order, :paid, listing: in_process_listing, stripe_payment_intent_id: "pi_failed")
      failed_intent = OpenStruct.new(id: "pi_failed")
      event = OpenStruct.new(type: "payment_intent.payment_failed", data: OpenStruct.new(object: failed_intent))
      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post stripe_webhook_path, params: "{}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("failed")
      expect(in_process_listing.reload.status).to eq("unsold")
    end

    it "returns ok for unhandled event types" do
      event = OpenStruct.new(type: "charge.refunded", data: OpenStruct.new(object: OpenStruct.new(id: "obj_1")))
      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

      post stripe_webhook_path, params: "{}", headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
