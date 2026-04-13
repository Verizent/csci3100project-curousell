require "rails_helper"

RSpec.describe Order, type: :model do
  describe "associations" do
    it "has expected associations" do
      expect(described_class.reflect_on_association(:listing)&.macro).to eq(:belongs_to)
      expect(described_class.reflect_on_association(:buyer)&.macro).to eq(:belongs_to)
      expect(described_class.reflect_on_association(:seller)&.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    subject(:order) { build(:order) }

    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending completed cancelled refunded]) }
    it { is_expected.to validate_numericality_of(:price_at_purchase).is_greater_than_or_equal_to(0) }

    it "is invalid without a buyer" do
      order.buyer = nil
      expect(order).not_to be_valid
    end

    it "is invalid without a seller" do
      order.seller = nil
      expect(order).not_to be_valid
    end

    it "is invalid without a listing" do
      order.listing = nil
      expect(order).not_to be_valid
    end

    it "allows free-item orders" do
      expect(build(:order, :free_item)).to be_valid
    end

    it "rejects negative purchase prices" do
      expect(build(:order, price_at_purchase: -1)).not_to be_valid
    end
  end

  describe "callbacks" do
    it "sets purchase price from listing if omitted" do
      listing = create(:listing, price: 88.50)
      order = create(:order, listing: listing, seller: listing.user, price_at_purchase: nil)

      expect(order.price_at_purchase).to eq(88.50)
    end

    it "marks listing as in_process when order is created" do
      listing = create(:listing, status: "unsold")

      create(:order, listing: listing, seller: listing.user)

      expect(listing.reload.status).to eq("in_process")
    end
  end

  describe "confirmation flow (current implementation)" do
    let(:seller) { create(:user) }
    let(:buyer) { create(:user) }
    let(:listing) { create(:listing, user: seller, status: "unsold") }
    let(:order) { create(:order, listing: listing, seller: seller, buyer: buyer, status: "pending") }

    it "records seller confirmation timestamp" do
      freeze_time do
        order.seller_confirm!
        expect(order.reload.seller_confirmed_at).to eq(Time.current)
        expect(order.status).to eq("pending")
      end
    end

    it "records buyer confirmation timestamp" do
      freeze_time do
        order.buyer_confirm!
        expect(order.reload.buyer_confirmed_at).to eq(Time.current)
        expect(order.status).to eq("pending")
      end
    end

    it "moves order to completed once both parties confirm" do
      order.seller_confirm!

      freeze_time do
        order.buyer_confirm!
        order.reload

        expect(order.status).to eq("completed")
        expect(order.completed_at).to eq(Time.current)
        expect(order.listing.reload.status).to eq("sold")
      end
    end

    it "does not complete when only one side confirms" do
      order.seller_confirm!

      expect(order.reload.status).to eq("pending")
      expect(order.completed_at).to be_nil
      expect(order.listing.reload.status).to eq("in_process")
    end
  end

  describe "cancellation" do
    let(:listing) { create(:listing, status: "unsold") }
    let(:order) { create(:order, listing: listing, seller: listing.user, status: "pending") }

    it "marks order as cancelled" do
      order.cancel!
      expect(order.reload.status).to eq("cancelled")
    end

    it "restores in_process listing back to unsold" do
      order
      expect(listing.reload.status).to eq("in_process")

      order.cancel!

      expect(listing.reload.status).to eq("unsold")
    end
  end

  describe "planned state machine requirements" do
    it "supports seller delivered transition (pending -> delivered)" do
      skip("Not implemented: current app uses seller_confirmed_at while keeping status as pending")
    end

    it "supports buyer received transition (delivered -> received -> completed)" do
      skip("Not implemented: current app does not define delivered/received statuses")
    end

    it "prevents duplicate delivered/received transitions" do
      skip("Not implemented: requires explicit status state machine guards")
    end

    it "rejects received-before-delivered transition" do
      skip("Not implemented: requires explicit delivered/received statuses")
    end

    it "handles concurrent transition updates safely" do
      skip("Not implemented: requires locking/atomic transition policy")
    end

    it "supports delivered -> cancelled timeout policy" do
      skip("Policy to cancel delivered orders is not implemented; requirement needs finalization")
    end
  end
end
