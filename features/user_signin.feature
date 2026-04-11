Feature: User Signin
  As a registered CUHK student
  I want to sign in to CUrousell
  So that I can access the marketplace

  Background:
    Given a verified user exists with email "alice@link.cuhk.edu.hk" and password "SecurePassword123!"

  Scenario: Successful signin with 2FA
    Given I visit the signin page
    When I sign in with email "alice@link.cuhk.edu.hk" and password "SecurePassword123!"
    Then I should be on the 2FA verification page
    When I enter the 2FA OTP code
    And I click "Verify Email"
    Then I should be redirected to the home page
    And I should see "Welcome back"

  Scenario: Signin rejected with wrong password
    Given I visit the signin page
    When I sign in with email "alice@link.cuhk.edu.hk" and password "WrongPassword!"
    Then I should be on the signin page
    And I should see "Wrong email"

  Scenario: Signin rejected for an unverified account
    Given an unverified user exists with email "bob@link.cuhk.edu.hk" and password "SecurePassword123!"
    And I visit the signin page
    When I sign in with email "bob@link.cuhk.edu.hk" and password "SecurePassword123!"
    Then I should be on the verify email page

  Scenario: 2FA fails with wrong code
    Given I visit the signin page
    When I sign in with email "alice@link.cuhk.edu.hk" and password "SecurePassword123!"
    Then I should be on the 2FA verification page
    When I submit the 2FA form with code "000000"
    Then I should see "Incorrect code"
    And I should still be on the 2FA verification page

  Scenario: Sign out
    Given I am signed in as "alice@link.cuhk.edu.hk" with password "SecurePassword123!"
    When I sign out
    Then I should see "signed out"
