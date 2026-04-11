class ChatChannel < ApplicationCable::Channel
  # Action cable implementation: 
  # Subscription implies the user has a chat with some other user 
  # and the conversation_id is the id of the conversation between them
  # The channel will stream from "chat_#{conversation_id}" and broadcast messages to that stream
  # 
  #Speak action is when the user sends a message in the chat 
  #There are constraints done such as only participants of the 
  #conversation can join the chat/contribute to the chat (obviously, for the security reasons)
  #
  #
  def subscribed
    conversation = Conversation.find(params[:conversation_id])

    # Only allow participants to subscribe
    if conversation.participant?(current_user)
      stream_from "chat_#{params[:conversation_id]}"
    else
      reject
    end
  end

  def speak(data)
    return unless current_user

    conversation = Conversation.find(params[:conversation_id])
    return unless conversation.participant?(current_user)

    message = conversation.messages.create!(
      user_id: current_user.id,
      content: data["message"]
    )
    # The after_create_commit callback will broadcast automatically
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
