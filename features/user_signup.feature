Feature: User Sign Up
  As a CUHK student
  I want to create an account on Curousell
  So that I can buy and sell items on the platform

  Scenario: Successful signup with valid OTP
    Given I am on the sign up page
    When I fill in the signup form with valid details
    And I accept the Terms & Conditions
    And I click "Create Account"
    Then I should be on the verify page
    When I submit the signup OTP
    Then I should be on the sign in page
    And I should see "Email verified"

  Scenario: Signup without accepting terms
    Given I am on the sign up page
    When I fill in the signup form with valid details
    And I click "Create Account"
    Then I should see "Terms & Conditions"

  Scenario: Signup with a non-CUHK email
    Given I am on the sign up page
    When I fill in the signup form with email "student@gmail.com"
    And I accept the Terms & Conditions
    And I click "Create Account"
    Then I should see "must be a CUHK email"

  Scenario: Signup OTP incorrect
    Given I am on the sign up page
    When I fill in the signup form with valid details
    And I accept the Terms & Conditions
    And I click "Create Account"
    Then I should be on the verify page
    When I submit an incorrect OTP "000000"
    Then I should see "Incorrect code"

  Scenario: Signup OTP max attempts reached
    Given I am on the sign up page
    When I fill in the signup form with valid details
    And I accept the Terms & Conditions
    And I click "Create Account"
    Then I should be on the verify page
    When I submit an incorrect OTP "000000" 3 times
    Then I should be on the sign up page
    And I should see "Maximum attempts"
