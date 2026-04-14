Feature: User Profile
  As a signed-in CUHK user
  I want to view my profile page
  So that I can see my account information

  Background:
    Given a verified user exists with email "student@cuhk.edu.hk" and password "securepassword123"

  Scenario: Viewing profile when signed in
    Given I am signed in as "student@cuhk.edu.hk" with password "securepassword123"
    When I visit the profile page
    Then I should be on the profile page
    And I should see "Test Student"
    And I should see "student@cuhk.edu.hk"
    And I should see "Shaw College"
    And I should see "Faculty of Engineering"

  Scenario: Redirected to sign-in when visiting profile without being logged in
    When I visit the profile page
    Then I should be on the sign in page
    And I should see "Please log in"
