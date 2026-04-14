Feature: Listing edit management
  As a seller
  I want edit-listing controls to follow business rules
  So that deletion and media actions behave correctly

  Background:
    Given a verified user exists with email "edit_seller@link.cuhk.edu.hk" and password "SecurePassword123!" and college "Shaw College"

  Scenario: Edit menu shows only price input, delete action, and no removed fields
    Given a listing "Edit Flow Item" exists by "edit_seller@link.cuhk.edu.hk"
    And I am signed in as "edit_seller@link.cuhk.edu.hk" with password "SecurePassword123!"
    When I visit the edit listing page for "Edit Flow Item"
    Then I should see "Delete Listing"
    And I should not see "Add Photos"
    And I should not see "Meeting Place"
    And I should not see "Restrict Audience"
    And I should not see "negotiable"

  Scenario: Delete is disabled in edit menu after seller confirmed delivery
    Given a listing "Delivered Item" exists by "edit_seller@link.cuhk.edu.hk"
    And the seller has confirmed delivery for listing "Delivered Item"
    And I am signed in as "edit_seller@link.cuhk.edu.hk" with password "SecurePassword123!"
    When I visit the edit listing page for "Delivered Item"
    Then I should see "Delete is disabled after delivery has been confirmed"
    And I should not see "Delete Listing"

  Scenario: Seller can update price from edit menu
    Given a listing "Priced Item" exists by "edit_seller@link.cuhk.edu.hk"
    And I am signed in as "edit_seller@link.cuhk.edu.hk" with password "SecurePassword123!"
    When I visit the edit listing page for "Priced Item"
    And I fill in "Price" with "999"
    And I click "Update Listing"
    Then I should see "Listing updated successfully"

  Scenario: Seller can delete listing from edit menu before delivery confirmation
    Given a listing "Deletable Item" exists by "edit_seller@link.cuhk.edu.hk"
    And I am signed in as "edit_seller@link.cuhk.edu.hk" with password "SecurePassword123!"
    When I visit the edit listing page for "Deletable Item"
    And I delete listing "Deletable Item" from the edit page
    Then listing "Deletable Item" should not exist
    And I should be redirected to the home page
