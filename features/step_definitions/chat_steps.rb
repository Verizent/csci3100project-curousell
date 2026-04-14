Given("the following listing exists:") do |table|
  new_listing = table.hashes.first
  seller = User.find_by(email: new_listing["seller_email"])

  @listing = Listing.create!(
    title: new_listing["title"],
    price: new_listing["price"].to_i,
    description: "Test listing",
    location: "CUHK",
    category: "books",
    status: "unsold",
    user: seller
  )
end

Given("a conversation exists between {string} and {string} about {string}") do |buyer_email, seller_email, listing_title|
  buyer = User.find_by(email: buyer_email)
  seller = User.find_by(email: seller_email)
  listing = Listing.find_by(title: listing_title)

  @conversation = Conversation.create!(
    sender: buyer,
    receiver: seller,
    listing: listing
  )
end

Given("a conversation exists between {string} and {string} about {string} with message {string}") do |buyer_email, seller_email, listing_title, message_content|
  buyer = User.find_by(email: buyer_email)
  seller = User.find_by(email: seller_email)
  listing = Listing.find_by(title: listing_title)
  @conversation = Conversation.create!(
    sender: buyer,
    receiver: seller,
    listing: listing
  )
  Message.create!(
    conversation: @conversation,
    user: buyer,
    content: message_content
  )
end

Given("a conversation already exists between {string} and {string} about {string}") do |buyer_email, seller_email, listing_title|
  buyer = User.find_by(email: buyer_email)
  seller = User.find_by(email: seller_email)
  listing = Listing.find_by(title: listing_title)
  @conversation = Conversation.create!(
    sender: buyer,
    receiver: seller,
    listing: listing
  )
end

When("I am on the listing page for {string}") do |listing_title|
  listing = Listing.find_by(title: listing_title)
  visit listing_path(listing)
end

When("I go to the listing page for {string}") do |listing_title|
  listing = Listing.find_by(title: listing_title)
  visit listing_path(listing)
end

When("I go to the chats index page") do
  visit chats_path
end

When("I go to the chat page for that conversation") do
  visit chat_path(@conversation)
end

When("I try to access that conversation's chat page") do
  visit chat_path(@conversation)
end

When("I click the chat with seller link") do
  click_link "Chat with Seller"
end

When("I fill in the new message form with {string}") do |message|
  fill_in "message_content", with: message
end

When("I click the send message button") do
  click_button "Send Message"
end

When("I fill in the message input with {string}") do |value|
  fill_in "message-input", with: value
end

When("I click the send button") do
  find("#send-button").click
end

Then("I should be on the chat page for the conversation") do
  expect(current_path).to match(%r{/chats/\d+})
end

Then("I should be on the chat page for the existing conversation") do
  expect(current_path).to eq(chat_path(@conversation))
end

Then("I should see {string} in the conversation") do |text|
  expect(page).to have_content(text)
end

Then("I should be redirected to the chats index page") do
  expect(current_path).to eq(chats_path)
end

Then("I should see an error message about empty message") do
  expect(page).to have_content("can't be blank") || have_content("required")
end
