require "rails_helper"

RSpec.describe CancelOldPendingOrdersJob, type: :job do
  describe "#perform" do
    it "cancels pending orders older than 1 hour and reverts listing to unsold" do
      listing = create(:listing, status: "in_process")
      order = create(:order, listing: listing, status: "pending", created_at: 2.hours.ago)

      described_class.perform_now

      expect(order.reload.status).to eq("cancelled")
      expect(listing.reload.status).to eq("unsold")
    end

    it "does not cancel pending orders created within the last hour" do
      listing = create(:listing, status: "in_process")
      order = create(:order, listing: listing, status: "pending", created_at: 30.minutes.ago)

      described_class.perform_now

      expect(order.reload.status).to eq("pending")
      expect(listing.reload.status).to eq("in_process")
    end

    it "does not affect paid orders" do
      order = create(:order, :paid, created_at: 2.hours.ago)

      described_class.perform_now

      expect(order.reload.status).to eq("paid")
    end

    it "does nothing when there are no expired orders" do
      expect { described_class.perform_now }.not_to raise_error
    end
  end
end
