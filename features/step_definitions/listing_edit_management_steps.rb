require "factory_bot_rails"

Given("the seller has confirmed delivery for listing {string}") do |title|
  listing = Listing.find_by!(title: title)
  buyer = create(:user, email: "edit_buyer_#{SecureRandom.hex(4)}@link.cuhk.edu.hk", college: "United College")
  create(:order, :paid, :seller_confirmed, listing: listing, buyer: buyer)
end

When("I visit the edit listing page for {string}") do |title|
  listing = Listing.find_by!(title: title)
  visit edit_listing_path(listing)
end

When("I delete listing {string} from the edit page") do |_title|
  click_link "Delete Listing"
end

Then("listing {string} should not exist") do |title|
  expect(Listing.find_by(title: title)).to be_nil
end
