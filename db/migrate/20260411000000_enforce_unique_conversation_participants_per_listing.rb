class EnforceUniqueConversationParticipantsPerListing < ActiveRecord::Migration[8.1]
  def up
    add_index :conversations,
              [ :sender_id, :receiver_id, :listing_id ],
              unique: true,
              name: "index_conversations_on_sender_receiver_listing"
  end

  def down
    remove_index :conversations, name: "index_conversations_on_sender_receiver_listing"
  end
end
