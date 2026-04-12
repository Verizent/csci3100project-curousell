require 'rails_helper'

RSpec.describe Listing, type: :model do
  let(:shaw_user) do
    User.create!(
      name: "Shaw Student",
      email: "shaw@cuhk.edu.hk",
      college: "Shaw College",
      faculty: [ "Faculty of Engineering" ],
      department: [ "Department of Computer Science and Engineering" ],
      password: "securepassword123",
      password_confirmation: "securepassword123",
      verified_at: Time.current
    )
  end

  let(:united_user) do
    User.create!(
      name: "United Student",
      email: "united@cuhk.edu.hk",
      college: "United College",
      faculty: [ "Faculty of Arts" ],
      department: [ "Department of English" ],
      password: "securepassword123",
      password_confirmation: "securepassword123",
      verified_at: Time.current
    )
  end

  let(:public_listing) do
    Listing.create!(title: "Public Item", description: "desc", price: 10, category: "tech", status: "unsold", user: shaw_user)
  end

  let(:shaw_only_listing) do
    Listing.create!(
      title: "Shaw Only", description: "desc", price: 10, category: "tech", status: "unsold", user: shaw_user,
      access_rules_attributes: [ { colleges: [ "Shaw College" ], departments: [], faculties: [] } ]
    )
  end

  let(:engineering_only_listing) do
    Listing.create!(
      title: "Engineering Only", description: "desc", price: 10, category: "tech", status: "unsold", user: shaw_user,
      access_rules_attributes: [ { colleges: [], departments: [], faculties: [ "Faculty of Engineering" ] } ]
    )
  end

  describe "validations" do
    it "is invalid without a title" do
      listing = Listing.new(title: "", price: 10, category: "tech", status: "unsold", user: shaw_user)
      expect(listing).not_to be_valid
    end

    it "is invalid with a negative price" do
      listing = Listing.new(title: "Item", price: -1, category: "tech", status: "unsold", user: shaw_user)
      expect(listing).not_to be_valid
    end

    it "is invalid with an unknown category" do
      listing = Listing.new(title: "Item", price: 10, category: "unknown", status: "unsold", user: shaw_user)
      expect(listing).not_to be_valid
    end
  end

  describe ".visible_to" do
    context "with no user (guest)" do
      it "includes listings with no access rules" do
        public_listing
        expect(Listing.visible_to(nil)).to include(public_listing)
      end

      it "excludes listings with access rules" do
        shaw_only_listing
        expect(Listing.visible_to(nil)).not_to include(shaw_only_listing)
      end
    end

    context "with a logged-in user" do
      it "includes public listings" do
        public_listing
        expect(Listing.visible_to(shaw_user)).to include(public_listing)
      end

      it "includes listings matching the user's college" do
        shaw_only_listing
        expect(Listing.visible_to(shaw_user)).to include(shaw_only_listing)
      end

      it "excludes listings restricted to another college" do
        shaw_only_listing
        expect(Listing.visible_to(united_user)).not_to include(shaw_only_listing)
      end

      it "includes listings matching the user's faculty" do
        engineering_only_listing
        expect(Listing.visible_to(shaw_user)).to include(engineering_only_listing)
      end

      it "excludes listings restricted to another faculty" do
        engineering_only_listing
        expect(Listing.visible_to(united_user)).not_to include(engineering_only_listing)
      end
    end
  end

  describe ".search" do
    before do
      Listing.create!(title: "Calculus Textbook", description: "Math book", price: 50, category: "books", status: "unsold", user: shaw_user)
      Listing.create!(title: "Guitar", description: "Musical instrument", price: 200, category: "miscellaneous", status: "unsold", user: shaw_user)
    end

    it "returns all listings when query is blank" do
      expect(Listing.search("").count).to eq(2)
    end

    it "finds listings by title" do
      expect(Listing.search("Calculus").map(&:title)).to include("Calculus Textbook")
    end

    it "does not return unrelated listings" do
      expect(Listing.search("Calculus").map(&:title)).not_to include("Guitar")
    end
  end
end
