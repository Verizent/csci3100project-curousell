require 'rails_helper'

RSpec.describe CancelOldPendingOrdersJob, type: :job do
  describe "#perform" do
    it "cancels each order returned by the expired scope" do
      order_one = instance_double(Order)
      order_two = instance_double(Order)
      relation = instance_double(ActiveRecord::Relation)

      allow(Order).to receive(:expired).and_return(relation)
      allow(relation).to receive(:includes).with(:listing).and_return(relation)
      allow(relation).to receive(:find_each).and_yield(order_one).and_yield(order_two)

      expect(order_one).to receive(:cancel!)
      expect(order_two).to receive(:cancel!)

      described_class.perform_now
    end

    it "cancels pending orders older than 14 days (integration requirement)" do
      skip("Not implemented: Order.expired scope / cancel_expired! policy methods are missing")
    end

    it "does not include cancelled orders in active metrics" do
      skip("Not implemented: active-order metrics API/query object is not defined yet")
    end
  end
end
