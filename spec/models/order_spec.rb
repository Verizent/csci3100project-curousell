require "rails_helper"

RSpec.describe Order, type: :model do
  describe "associations" do
    it "belongs to buyer" do
      expect(described_class.reflect_on_association(:buyer)&.macro).to eq(:belongs_to)
    end

    it "belongs to listing" do
      expect(described_class.reflect_on_association(:listing)&.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "is invalid without amount_cents" do
      order = build(:order, amount_cents: nil)
      expect(order).not_to be_valid
    end

    it "is invalid with negative amount" do
      order = build(:order, amount_cents: -1)
      expect(order).not_to be_valid
    end

    it "is invalid without currency" do
      order = build(:order, currency: nil)
      expect(order).not_to be_valid
    end

    it "is invalid with an unknown status" do
      order = build(:order, status: "unknown")
      expect(order).not_to be_valid
    end

    it "is valid with a known status" do
      Order::STATUSES.each do |s|
        expect(build(:order, status: s)).to be_valid
      end
    end
  end

  describe "#seller" do
    it "returns the listing's user" do
      seller = create(:user)
      listing = create(:listing, user: seller)
      order = create(:order, listing: listing)
      expect(order.seller).to eq(seller)
    end
  end

  describe "#amount" do
    it "converts cents to decimal" do
      order = build(:order, amount_cents: 12000)
      expect(order.amount).to eq(120.0)
    end
  end

  describe "confirmation flow" do
    let(:seller) { create(:user) }
    let(:listing) { create(:listing, user: seller, status: "in_process") }
    let(:order) { create(:order, listing: listing, status: "paid") }

    it "records buyer confirmation timestamp" do
      freeze_time do
        order.confirm_by_buyer!
        expect(order.reload.buyer_confirmed_at).to eq(Time.current)
      end
    end

    it "records seller confirmation timestamp" do
      freeze_time do
        order.confirm_by_seller!
        expect(order.reload.seller_confirmed_at).to eq(Time.current)
      end
    end

    it "completes order when both parties confirm" do
      order.confirm_by_seller!
      order.confirm_by_buyer!

      expect(order.reload.status).to eq("completed")
      expect(listing.reload.status).to eq("sold")
    end

    it "does not complete when only one side confirms" do
      order.confirm_by_seller!
      expect(order.reload.status).to eq("paid")
    end

    it "is idempotent — confirming twice does not duplicate" do
      order.confirm_by_buyer!
      order.confirm_by_buyer!
      expect(order.reload.status).to eq("paid")
    end
  end

  describe ".expired scope" do
    it "includes pending orders older than 1 hour" do
      order = create(:order, status: "pending", created_at: 2.hours.ago)
      expect(Order.expired).to include(order)
    end

    it "excludes pending orders created within the last hour" do
      order = create(:order, status: "pending", created_at: 30.minutes.ago)
      expect(Order.expired).not_to include(order)
    end

    it "excludes non-pending orders regardless of age" do
      paid_order = create(:order, :paid, created_at: 2.hours.ago)
      expect(Order.expired).not_to include(paid_order)
    end
  end

  describe "#cancel!" do
    it "cancels a pending order and reverts listing to unsold" do
      listing = create(:listing, status: "in_process")
      order = create(:order, listing: listing, status: "pending")

      order.cancel!

      expect(order.reload.status).to eq("cancelled")
      expect(listing.reload.status).to eq("unsold")
    end

    it "does nothing if order is not pending" do
      order = create(:order, :paid)

      order.cancel!

      expect(order.reload.status).to eq("paid")
    end
  end

  describe "#mark_failed!" do
    it "marks order as failed and reverts listing to unsold" do
      listing = create(:listing, status: "in_process")
      order = create(:order, listing: listing, status: "paid")

      order.mark_failed!

      expect(order.reload.status).to eq("failed")
      expect(listing.reload.status).to eq("unsold")
    end
  end

  describe "#auto_cancel!" do
    it "refunds a paid order and reverts listing to unsold" do
      listing = create(:listing, status: "in_process")
      order = create(:order, listing: listing, status: "paid", stripe_payment_intent_id: "pi_test")

      allow(Stripe::Refund).to receive(:create)

      order.auto_cancel!

      expect(order.reload.status).to eq("refunded")
      expect(listing.reload.status).to eq("unsold")
      expect(Stripe::Refund).to have_received(:create).with(payment_intent: "pi_test")
    end

    it "does nothing if order is not paid" do
      order = create(:order, status: "completed")
      order.auto_cancel!
      expect(order.reload.status).to eq("completed")
    end
  end
end
