class Conversation < ApplicationRecord
  # our database for conversation is item-based, as such two different items sold by the same seller will make
  # two separate chats with the same buyer

  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :listing
  has_many :messages, dependent: :destroy

  validate :unique_participant_pair_per_listing
  # this ensure that every conversation is unique on the following attributes (buyer_id, seller_id, and item_id)


  # Get the other participant in the conversation
  def other_participant(current_user)
    sender == current_user ? receiver : sender
  end

  # Get the last message in this conversation
  def last_message
    messages.order(created_at: :desc).first
  end

  # Check if user is a participant
  def participant?(user)
    return false if user.nil?
    # if the user is not logged in, the website will not allow them to access the chat page
    # prevents any potential web crash
    sender_id == user.id || receiver_id == user.id
  end

  # Scope to get conversations for a user (either as sender or receiver)
  scope :for_user, ->(user) { where("sender_id = ? OR receiver_id = ?", user.id, user.id) }

  private

  # Prevent duplicate conversations for the same two users on the same item,
  # regardless of sender/receiver direction. This is especially important when dealing with creating
  # new chats from "chat with seller" as during development it was found that the new chat for the same item gets created despite
  # primary key enforcement
  def unique_participant_pair_per_listing
    return if sender_id.blank? || receiver_id.blank? || listing_id.blank?

    left_id, right_id = [ sender_id, receiver_id ].minmax

    duplicate_exists = Conversation
      .where(listing_id: listing_id)
      .where("LEAST(sender_id, receiver_id) = ? AND GREATEST(sender_id, receiver_id) = ?", left_id, right_id)
      .where.not(id: id)
      .exists?

    if duplicate_exists
      errors.add(:base, "Conversation already exists for this buyer, seller, and item")
    end
  end
end
