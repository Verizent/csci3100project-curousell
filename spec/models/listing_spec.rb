require "rails_helper"

RSpec.describe Listing, type: :model do
  subject { build(:listing) }

  # ---------------------------------------------------------------------------
  # Associations & validations
  # ---------------------------------------------------------------------------

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(100) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_inclusion_of(:category).in_array(Listing::CATEGORIES) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Listing::STATUSES) }

    it "is invalid with a negative price" do
      subject.price = -1
      expect(subject).not_to be_valid
      expect(subject.errors[:price]).to be_present
    end

    it "is valid with a price of 0 (free item)" do
      subject.price = 0
      expect(subject).to be_valid
    end

    it "is invalid with a blank title" do
      subject.title = ""
      expect(subject).not_to be_valid
    end

    it "is invalid with a title over 100 characters" do
      subject.title = "a" * 101
      expect(subject).not_to be_valid
    end
  end

  # ---------------------------------------------------------------------------
  # Constants
  # ---------------------------------------------------------------------------

  describe "CATEGORIES" do
    it "includes the expected categories" do
      expect(Listing::CATEGORIES).to include("furniture", "tech", "books", "clothing", "accessories", "miscellaneous")
    end
  end

  describe "STATUSES" do
    it "includes the expected statuses" do
      expect(Listing::STATUSES).to include("unsold", "in_process", "sold")
    end
  end

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------

  describe ".by_category" do
    let(:user) { create(:user) }
    let!(:tech_listing) { create(:listing, category: "tech",  user: user) }
    let!(:book_listing) { create(:listing, category: "books", user: user) }

    it "returns only listings of the given category" do
      result = Listing.by_category("tech")
      expect(result).to include(tech_listing)
      expect(result).not_to include(book_listing)
    end

    it "returns all listings when category is nil" do
      result = Listing.by_category(nil)
      expect(result).to include(tech_listing, book_listing)
    end

    it "returns all listings when category is blank string" do
      result = Listing.by_category("")
      expect(result).to include(tech_listing, book_listing)
    end
  end

  describe ".by_status" do
    let(:user) { create(:user) }
    let!(:unsold) { create(:listing, status: "unsold",    user: user) }
    let!(:sold)   { create(:listing, status: "sold",      user: user) }
    let!(:active) { create(:listing, status: "in_process", user: user) }

    it "returns only listings with the given status" do
      result = Listing.by_status("unsold")
      expect(result).to include(unsold)
      expect(result).not_to include(sold, active)
    end

    it "returns all listings when status is nil" do
      result = Listing.by_status(nil)
      expect(result).to include(unsold, sold, active)
    end
  end

  describe ".visible_to" do
    let(:shaw_user) do
      create(:user,
        college: "Shaw College",
        faculty: [ "Faculty of Engineering" ],
        department: [ "Department of Computer Science and Engineering" ])
    end

    let(:united_user) do
      create(:user,
        college: "United College",
        faculty: [ "Faculty of Arts" ],
        department: [ "Department of English" ])
    end

    let!(:public_listing) { create(:listing, user: shaw_user) }

    let!(:shaw_only_listing) do
      listing = create(:listing, user: shaw_user)
      create(:listing_access_rule, listing: listing,
        colleges: [ "Shaw College" ], faculties: [], departments: [])
      listing
    end

    let!(:united_only_listing) do
      listing = create(:listing, user: shaw_user)
      create(:listing_access_rule, listing: listing,
        colleges: [ "United College" ], faculties: [], departments: [])
      listing
    end

    context "when user is nil (guest)" do
      it "returns only unrestricted listings" do
        result = Listing.visible_to(nil)
        expect(result).to include(public_listing)
        expect(result).not_to include(shaw_only_listing, united_only_listing)
      end
    end

    context "when user is from Shaw College" do
      it "shows unrestricted listings" do
        expect(Listing.visible_to(shaw_user)).to include(public_listing)
      end

      it "shows listings restricted to Shaw College" do
        expect(Listing.visible_to(shaw_user)).to include(shaw_only_listing)
      end

      it "hides listings restricted to United College" do
        expect(Listing.visible_to(shaw_user)).not_to include(united_only_listing)
      end
    end

    context "when user is from United College" do
      it "shows unrestricted listings" do
        expect(Listing.visible_to(united_user)).to include(public_listing)
      end

      it "shows listings restricted to United College" do
        expect(Listing.visible_to(united_user)).to include(united_only_listing)
      end

      it "hides listings restricted to Shaw College" do
        expect(Listing.visible_to(united_user)).not_to include(shaw_only_listing)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # #restricted?
  # ---------------------------------------------------------------------------

  describe "#restricted?" do
    let(:user) { create(:user) }

    it "returns false for a listing with no access rules" do
      listing = create(:listing, user: user)
      expect(listing.restricted?).to be false
    end

    it "returns true for a listing that has access rules" do
      listing = create(:listing, user: user)
      create(:listing_access_rule, listing: listing, colleges: [ "Shaw College" ], faculties: [], departments: [])
      listing.reload
      expect(listing.restricted?).to be true
    end
  end
end
