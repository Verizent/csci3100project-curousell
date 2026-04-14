Feature: Chat Functionality
  As a verified CUHK student
  I want to chat with other users about listings
  So that I can negotiate and communicate about items for sale

  Background:
    Given a verified user exists with email "seller@link.cuhk.edu.hk" and password "password12356"
    And a verified user exists with email "buyer@link.cuhk.edu.hk" and password "password123456"
    And the following listing exists:
      | title         | price | seller_email            |
      | Calculus Book | 20    | seller@link.cuhk.edu.hk |

  Scenario: Buyer starts a conversation about a listing
    Given I am signed in as "buyer@link.cuhk.edu.hk" with password "password123456"
    And I am on the listing page for "Calculus Book"
    When I click the chat with seller link
    And I fill in the new message form with "Yo, is this open to bargain?"
    And I click the send message button
    Then I should be on the chat page for the conversation
    And I should see "Yo, is this open to bargain?"

  Scenario: Seller cannot start a conversation about their own listing
    Given I am signed in as "seller@link.cuhk.edu.hk" with password "password12356"
    And I am on the listing page for "Calculus Book"
    Then I should see "This is your listing"
    And I should not see "Chat with Seller"

  Scenario: User views a specific conversation
    Given I am signed in as "buyer@link.cuhk.edu.hk" with password "password123456"
    And a conversation exists between "buyer@link.cuhk.edu.hk" and "seller@link.cuhk.edu.hk" about "Calculus Book" with message "How much is this?"
    When I go to the chat page for that conversation
    Then I should see "Calculus Book"
    And I should see "How much is this?"

  Scenario: Cannot create duplicate conversation for same listing and users
    Given I am signed in as "buyer@link.cuhk.edu.hk" with password "password123456"
    And a conversation already exists between "buyer@link.cuhk.edu.hk" and "seller@link.cuhk.edu.hk" about "Calculus Book"
    When I go to the listing page for "Calculus Book"
    And I click the chat with seller link
    And I fill in the new message form with "Same_convo message"
    And I click the send message button
    Then I should be on the chat page for the existing conversation
    And I should see "Same_convo message"

  Scenario: Third party cannot access a conversation they're not part of
    Given a verified user exists with email "stranger@link.cuhk.edu.hk" and password "password123456"
    And a conversation exists between "buyer@link.cuhk.edu.hk" and "seller@link.cuhk.edu.hk" about "Calculus Book"
    When I am signed in as "stranger@link.cuhk.edu.hk" with password "password123456"
    And I try to access that conversation's chat page
    Then I should be redirected to the chats index page
    And I should see "You don't have access to this conversation"
