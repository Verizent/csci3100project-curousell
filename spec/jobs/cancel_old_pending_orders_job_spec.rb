require "rails_helper"

RSpec.describe AutoCancelOrderJob, type: :job do
  describe "#perform" do
    it "refunds a paid order and reverts listing to unsold" do
      listing = create(:listing, status: "in_process")
      order = create(:order, listing: listing, status: "paid", stripe_payment_intent_id: "pi_test")

      allow(Stripe::Refund).to receive(:create)

      described_class.perform_now(order.id)

      expect(order.reload.status).to eq("refunded")
      expect(listing.reload.status).to eq("unsold")
    end

    it "does nothing if order is already completed" do
      order = create(:order, :completed)

      described_class.perform_now(order.id)

      expect(order.reload.status).to eq("completed")
    end

    it "does nothing if order does not exist" do
      expect { described_class.perform_now(-1) }.not_to raise_error
    end
  end
end
