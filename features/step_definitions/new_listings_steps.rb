Given("a listing {string} exists by {string}") do |title, email|
  user = User.find_by!(email: email)
  @listing = Listing.create!(
    title: title,
    description: "Test description",
    price: 100,
    category: "miscellaneous",
    status: "unsold",
    user: user
  )
end

Given("a listing {string} restricted to {string} exists by {string}") do |title, college, email|
  user = User.find_by!(email: email)
  @listing = Listing.create!(
    title: title,
    description: "Test description",
    price: 100,
    category: "miscellaneous",
    status: "unsold",
    user: user,
    access_rules_attributes: [ { colleges: [ college ], departments: [], faculties: [] } ]
  )
end

Given("a verified user from {string} exists with email {string} and password {string}") do |college, email, password|
  User.create!(
    name: "Other Student",
    email: email,
    college: college,
    faculty: [ "Faculty of Arts" ],
    department: [ "Department of English" ],
    password: password,
    password_confirmation: password,
    verified_at: Time.current
  )
end

When("I visit the new listing page") do
  visit new_listing_path
end

When("I visit the listing for {string}") do |title|
  listing = Listing.find_by!(title: title)
  visit listing_path(listing)
end
