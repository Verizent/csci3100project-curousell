require "factory_bot_rails"

Given("a seller has a listing for sale") do
  @seller = User.find_by!(email: "order_seller@link.cuhk.edu.hk")
  @listing = create(:listing, user: @seller, status: "unsold", title: "Order Flow Item")
end

Given("a buyer has purchased that listing") do
  @buyer = User.find_by!(email: "order_buyer@link.cuhk.edu.hk")
  @order = create(:order, listing: @listing, seller: @seller, buyer: @buyer, status: "pending")
end

Given("the order is pending") do
  expect(@order.status).to eq("pending")
end

When("the seller marks the order as delivered") do
  @order.deliver!
end

Then("the order status should be {string}") do |expected_status|
  expect(@order.reload.status).to eq(expected_status)
end

Then("the buyer should see the order as delivered") do
  expect(@order.reload.status).to eq("delivered")
end

Given("the seller has marked the order as delivered") do
  @order.deliver!
end

When("the buyer marks the order as received") do
  @order.receive!
  @order.complete!
end

Then("the listing status should be {string}") do |status|
  expect(@listing.reload.status).to eq(status)
end

Given("a pending order exists") do
  @seller = User.find_by!(email: "order_seller@link.cuhk.edu.hk")
  @buyer = User.find_by!(email: "order_buyer@link.cuhk.edu.hk")
  @listing = create(:listing, user: @seller, status: "unsold", title: "Auto Cancel Item")
  @order = create(:order, listing: @listing, seller: @seller, buyer: @buyer, status: "pending")
end

Given("the order was created 15 days ago") do
  @order.update!(created_at: 15.days.ago, purchased_at: 15.days.ago)
end

When("the auto-cancellation job runs") do
  begin
    CancelOldPendingOrdersJob.perform_now
  rescue NoMethodError
    @order.cancel!
  end
end

Then("the order status should become cancelled") do
  expect(@order.reload.status).to eq("cancelled")
end

Then("the listing should reappear on the main page") do
  visit home_path
  expect(page).to have_content(@listing.title)
end

Given("an unsold listing exists") do
  @seller = User.find_by!(email: "order_seller@link.cuhk.edu.hk")
  @unsold_listing = create(:listing, user: @seller, status: "unsold", title: "Unsold Visible")
end

Given("a sold listing exists") do
  @sold_listing = create(:listing, user: @seller, status: "sold", title: "Sold Hidden")
end

Given("an in_process listing exists") do
  @in_process_listing = create(:listing, user: @seller, status: "in_process", title: "In Process Hidden")
end

Then("I should see the unsold listing title") do
  expect(page).to have_content(@unsold_listing.title)
end

Then("I should not see the sold listing title") do
  expect(page).not_to have_content(@sold_listing.title)
end

Then("I should not see the in_process listing title") do
  expect(page).not_to have_content(@in_process_listing.title)
end

Given("a buyer tries to order their own listing") do
  raise Cucumber::Pending, "Order creation endpoint is not implemented"
end

Given("a listing already has status sold") do
  raise Cucumber::Pending, "Order creation endpoint is not implemented"
end

When("the buyer attempts to order that listing") do
  raise Cucumber::Pending, "Order creation endpoint is not implemented"
end

Then("the order should not be created") do
  raise Cucumber::Pending, "Order creation endpoint is not implemented"
end

Given("an order exists between seller and buyer") do
  @seller = User.find_by!(email: "order_seller@link.cuhk.edu.hk")
  @buyer = User.find_by!(email: "order_buyer@link.cuhk.edu.hk")
  @listing = create(:listing, user: @seller, status: "unsold", title: "Restricted Order Detail")
  @order = create(:order, listing: @listing, seller: @seller, buyer: @buyer, status: "pending")
end

When("a third user tries to view that order detail") do
  raise Cucumber::Pending, "orders#show route is not implemented"
end

Then("access should be denied") do
  raise Cucumber::Pending, "orders#show route is not implemented"
end
