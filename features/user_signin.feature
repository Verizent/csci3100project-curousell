Feature: User Sign In
  As a registered CUHK student
  I want to sign in to Curousell
  So that I can access the platform

  Background:
    Given a verified user exists with email "student@cuhk.edu.hk" and password "securepassword123"

  Scenario: Successful sign in with valid 2FA OTP
    Given I am on the sign in page
    When I fill in "Email Address" with "student@cuhk.edu.hk"
    And I fill in "Password" with "securepassword123"
    And I click "Sign In"
    Then I should be on the 2FA page
    When I submit the correct OTP
    Then I should be redirected to the home page
    And I should see "Welcome back"

  Scenario: Failed sign in with wrong password
    Given I am on the sign in page
    When I fill in "Email Address" with "student@cuhk.edu.hk"
    And I fill in "Password" with "wrongpassword"
    And I click "Sign In"
    Then I should be on the sign in page
    And I should see "Wrong email"

  Scenario: Sign in with unverified account
    Given an unverified user exists with email "unverified@cuhk.edu.hk" and password "securepassword123"
    And I am on the sign in page
    When I fill in "Email Address" with "unverified@cuhk.edu.hk"
    And I fill in "Password" with "securepassword123"
    And I click "Sign In"
    Then I should be on the verify page
    Then I should see "not verified"

  Scenario: 2FA OTP has expired
    Given I am on the sign in page
    When I fill in "Email Address" with "student@cuhk.edu.hk"
    And I fill in "Password" with "securepassword123"
    And I click "Sign In"
    Then I should be on the 2FA page
    When the OTP has expired
    And I submit the correct OTP
    Then I should be on the sign in page
    And I should see "expired"
