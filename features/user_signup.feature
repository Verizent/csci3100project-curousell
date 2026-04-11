Feature: User Signup
  As a CUHK student
  I want to create an account on CUrousell
  So that I can buy and sell items with fellow students

  # Signup form relies on a Stimulus JS controller to enable the submit button
  # after the terms checkbox is checked — all scenarios here need @javascript.

  @javascript
  Scenario: Successful signup and OTP verification
    Given I visit the signup page
    When I fill in the signup form with valid CUHK credentials
    And I check the terms and conditions checkbox
    And I submit the signup form
    Then I should be on the verify email page
    When I enter the OTP code sent to my email
    And I click "Verify Email"
    Then I should be on the signin page
    And I should see "Email verified"

  @javascript
  Scenario: Signup rejected without accepting terms
    Given I visit the signup page
    When I fill in the signup form with valid CUHK credentials
    But I do not check the terms and conditions checkbox
    Then the "Create Account" button should be disabled

  @javascript
  Scenario: Signup rejected with a non-CUHK email
    Given I visit the signup page
    When I fill in the signup form with email "hacker@gmail.com"
    And I check the terms and conditions checkbox
    And I submit the signup form
    Then I should see "must be a CUHK email address"

  @javascript
  Scenario: Signup rejected with a short password
    Given I visit the signup page
    When I fill in the signup form with password "Short1!"
    And I check the terms and conditions checkbox
    And I submit the signup form
    Then I should see "is too short"

  @javascript
  Scenario: OTP verification fails with a wrong code
    Given I have completed the signup form successfully
    When I enter an incorrect OTP code "000000"
    And I click "Verify Email"
    Then I should see "Incorrect code"
    And I should still be on the verify email page

  @javascript
  Scenario: Account destroyed after too many wrong OTP attempts
    Given I have completed the signup form successfully
    When I enter an incorrect OTP code "000000" 3 times
    Then I should be on the signup page
    And I should see "Maximum attempts reached"
