Feature: Feedback submission
  As a CUrousell visitor
  I want to submit feedback from the footer form
  So that the team can improve the platform

  Scenario: Submit feedback successfully
    When I visit the home page
    When I submit feedback with name "Alice", email "alice@example.com", and message "Great platform"
    Then I should see "Thanks for your feedback!"

  Scenario: Feedback submission fails with missing required data
    When I visit the home page
    When I submit feedback with name "Alice", email "", and message ""
    Then I should see "Please fill in all fields."
