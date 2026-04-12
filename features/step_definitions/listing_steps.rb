require "factory_bot_rails"

# ── Helpers ───────────────────────────────────────────────────────────────────

def default_seller
  @default_seller ||= User.find_by(email: "seller@link.cuhk.edu.hk") ||
                      create(:user, email: "seller@link.cuhk.edu.hk",
                                    college: "Shaw College")
end

# ── Given ─────────────────────────────────────────────────────────────────────

Given "a public listing exists with title {string} and category {string} and price {int}" do |title, category, price|
  @public_listing = create(:listing,
    user: default_seller,
    title: title,
    category: category.downcase,
    price: price)
end

Given "a listing exists with title {string} and category {string} and price {int}" do |title, category, price|
  create(:listing,
    user: default_seller,
    title: title,
    category: category.downcase,
    price: price)
end

Given "a free listing exists with title {string}" do |title|
  @free_listing = create(:listing, :free, user: default_seller, title: title)
end

Given "a Shaw-College-only listing exists with title {string}" do |title|
  listing = create(:listing, user: default_seller, title: title)
  create(:listing_access_rule, listing: listing,
    colleges: [ "Shaw College" ], faculties: [], departments: [])
  @restricted_listing = listing
end

# ── When ──────────────────────────────────────────────────────────────────────

When "I visit the home page" do
  visit home_path
end

When "I visit that restricted listing's page directly" do
  visit listing_path(@restricted_listing)
end

When "I click on {string}" do |text|
  click_link text
end

When "I filter by category {string}" do |label|
  click_link label
end

When "I filter by free items" do
  visit home_path(free: "1")
end

When "I search for {string}" do |query|
  visit home_path(q: query)
end
