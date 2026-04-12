require "rails_helper"

RSpec.describe ListingAccessRule, type: :model do
  let(:user)    { create(:user) }
  let(:listing) { create(:listing, user: user) }

  def build_rule(attrs = {})
    ListingAccessRule.new(
      { listing: listing, colleges: [], faculties: [], departments: [] }.merge(attrs)
    )
  end

  def create_rule(attrs = {})
    ListingAccessRule.create!(
      { listing: listing, colleges: [], faculties: [], departments: [] }.merge(attrs)
    )
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------

  describe "associations" do
    it "belongs to a listing" do
      rule = build_rule
      expect(rule).to respond_to(:listing)
      expect(rule.listing).to eq(listing)
    end
  end

  # ---------------------------------------------------------------------------
  # compact_arrays before_save callback
  # ---------------------------------------------------------------------------

  describe "compact_arrays before_save" do
    it "removes blank strings from colleges" do
      rule = create_rule(colleges: [ "Shaw College", "", "  " ])
      expect(rule.reload.colleges).to eq([ "Shaw College" ])
    end

    it "removes blank strings from faculties" do
      rule = create_rule(faculties: [ "Faculty of Arts", "" ])
      expect(rule.reload.faculties).to eq([ "Faculty of Arts" ])
    end

    it "removes blank strings from departments" do
      rule = create_rule(departments: [ "Department of English", "", " " ])
      expect(rule.reload.departments).to eq([ "Department of English" ])
    end

    it "preserves all non-blank values" do
      rule = create_rule(colleges: [ "Shaw College", "United College" ])
      expect(rule.reload.colleges).to eq([ "Shaw College", "United College" ])
    end

    it "results in empty array when all values are blank" do
      rule = create_rule(colleges: [ "", "  " ])
      expect(rule.reload.colleges).to eq([])
    end

    it "runs on update as well as create" do
      rule = create_rule(colleges: [ "Shaw College" ])
      rule.update!(colleges: [ "New Asia College", "" ])
      expect(rule.reload.colleges).to eq([ "New Asia College" ])
    end
  end
end
