Feature: Order management lifecycle
  As a CUHK student that is a buyer or seller
  I want to view an orders page
  So that I know the status of all my bought and sold items

  Background:
    Given a verified user exists with email "order_seller@link.cuhk.edu.hk" and password "SecurePassword123!" and college "Shaw College"
    And a verified user exists with email "order_buyer@link.cuhk.edu.hk" and password "SecurePassword123!" and college "United College"

  Scenario: Seller marks pending order as delivered
    Given a seller has a listing for sale
    And a buyer has purchased that listing
    And the order is pending
    When the seller marks the order as delivered
    Then the order status should be "delivered"
    And the buyer should see the order as delivered

  Scenario: Buyer marks delivered order as received
    Given a seller has a listing for sale
    And a buyer has purchased that listing
    And the seller has marked the order as delivered
    When the buyer marks the order as received
    Then the order status should be "completed"
    And the listing status should be "sold"

  Scenario: Order auto-cancels after 14 days
    Given a pending order exists
    And the order was created 15 days ago
    When the auto-cancellation job runs
    Then the order status should become cancelled
    And the listing should reappear on the main page

  Scenario: Main page only shows available listings
    Given an unsold listing exists
    And a sold listing exists
    And an in_process listing exists
    When I visit the home page
    Then I should see the unsold listing title
    And I should not see the sold listing title
    And I should not see the in_process listing title

  @pending_order_create
  Scenario: Buyer cannot create order for own listing
    Given a buyer tries to order their own listing
    Then the order should not be created

  @pending_order_create
  Scenario: Buyer cannot create order for sold listing
    Given a listing already has status sold
    When the buyer attempts to order that listing
    Then the order should not be created

  @pending_authz
  Scenario: Unauthorized user cannot view order details
    Given an order exists between seller and buyer
    When a third user tries to view that order detail
    Then access should be denied
