Feature: Listing Browsing
  As a visitor or signed-in user
  I want to browse listings on CUrousell
  So that I can find items to buy

  Background:
    Given a verified user exists with email "seller@link.cuhk.edu.hk" and password "SecurePassword123!" and college "Shaw College"
    And a public listing exists with title "Public Keyboard" and category "tech" and price 150

  Scenario: Guest can browse the home page
    When I visit the home page
    Then I should see "Public Keyboard"

  Scenario: Guest can view a public listing detail page
    When I visit the home page
    And I click on "Public Keyboard"
    Then I should see "Public Keyboard"

  Scenario: Guest cannot view a college-restricted listing
    Given a Shaw-College-only listing exists with title "Shaw Laptop"
    When I visit that restricted listing's page directly
    Then I should be redirected to the home page
    And I should see "not available"

  Scenario: Matching-college user can view a restricted listing
    Given a Shaw-College-only listing exists with title "Shaw Monitor"
    And I am signed in as a Shaw College user
    When I visit that restricted listing's page directly
    Then I should see "Shaw Monitor"

  Scenario: Filter listings by category
    Given a listing exists with title "Philosophy Book" and category "books" and price 20
    When I visit the home page
    And I filter by category "Tech"
    Then I should see "Public Keyboard"
    And I should not see "Philosophy Book"

  Scenario: Filter listings by free items
    Given a free listing exists with title "Free Desk Lamp"
    When I visit the home page
    And I filter by free items
    Then I should see "Free Desk Lamp"
    And I should not see "Public Keyboard"

  Scenario: Search for a listing by title
    When I visit the home page
    And I search for "Keyboard"
    Then I should see "Public Keyboard"
