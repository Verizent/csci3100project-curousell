class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :content, presence: true

  # Broadcast new message via Action Cable after creation
  after_create_commit { broadcast_message }

  def broadcast_message
    # Broadcast to the specific conversation channel
    ActionCable.server.broadcast(
      "chat_#{conversation_id}",
      {
        id: id,
        content: content,
        user_id: user_id,
        user_name: user.name,
        created_at: created_at.in_time_zone("Asia/Hong_Kong").strftime("%H:%M"),
        conversation_id: conversation_id
      }
    )
  end
end
