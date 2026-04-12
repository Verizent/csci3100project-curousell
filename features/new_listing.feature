Feature: Listings
  As a CUHK student
  I want to create and browse listings
  So that I can buy and sell items on campus

  Background:
    Given a verified user exists with email "seller@cuhk.edu.hk" and password "securepassword123"

  Scenario: Guest is redirected to sign in when visiting the new listing page
    When I visit the new listing page
    Then I should be on the sign in page
    And I should see "Please log in"

  Scenario: Logged-in user can post a new listing
    Given I am signed in as "seller@cuhk.edu.hk" with password "securepassword123"
    When I visit the new listing page
    And I fill in "Title" with "Calculus Textbook"
    And I fill in "Description" with "Good condition, barely used"
    And I fill in "Price" with "50"
    And I select "Books" from "Category"
    And I click "Post Listing"
    Then I should see "Your listing is live!"
    And I should see "Calculus Textbook"

  Scenario: Owner can view their own college-restricted listing
    Given I am signed in as "seller@cuhk.edu.hk" with password "securepassword123"
    And a listing "Private Textbook" restricted to "Shaw College" exists by "seller@cuhk.edu.hk"
    When I visit the listing for "Private Textbook"
    Then I should see "Private Textbook"

  Scenario: College-restricted listing is not visible to users from another college
    Given a listing "Shaw Only Item" restricted to "Shaw College" exists by "seller@cuhk.edu.hk"
    And a verified user from "United College" exists with email "other@cuhk.edu.hk" and password "securepassword123"
    And I am signed in as "other@cuhk.edu.hk" with password "securepassword123"
    When I visit the listing for "Shaw Only Item"
    Then I should be redirected to the home page
    And I should see "not available"
