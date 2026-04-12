class ChatsController < ApplicationController
  before_action :authenticate_user!

  # GET /chats - Show all conversations for current user
  def index
    @conversations = current_user.all_conversations
                                 .includes(:listing, :sender, :receiver, :messages)
                                 .order(created_at: :desc)
  end

  # GET /chats/:id - Show a specific conversation
  def show
    @conversation = Conversation.find(params[:id])

    # Security check - only participants can view
    unless @conversation.participant?(current_user)
      redirect_to chats_path, alert: "You don't have access to this conversation"
      return
    end

    @messages = @conversation.messages.order(created_at: :asc)
    @other_user = @conversation.other_participant(current_user)
  end

  # GET /chats/new?listing_id=X - Start a new conversation (pre-filled form)
  def new
    if params[:listing_id].present?
      @listing = Listing.find(params[:listing_id])

      # Can't chat with yourself
      if @listing.user_id == current_user.id
        redirect_to listing_path(@listing), alert: "You cannot message yourself"
        return
      end

      # Create unsaved conversation for the form (send_message action will handle creation)
      @conversation = Conversation.new(
        sender_id: current_user.id,
        receiver_id: @listing.user_id,
        listing_id: @listing.id
      )
    else
      redirect_to chats_path, alert: "Please select a listing to chat about"
    end
  end

  # POST /chats/send_message - Create conversation AND first message together
  # This is the key endpoint that creates conversation on first message
  def send_message
    listing = Listing.find(params[:listing_id])

    # Can't chat with yourself
    if listing.user_id == current_user.id
      redirect_to listing_path(listing), alert: "You cannot message yourself"
      return
    end

    # Find existing conversation regardless of sender/receiver direction
    conversation = Conversation.where(listing_id: listing.id)
                               .where(
                                 "(sender_id = :buyer AND receiver_id = :seller) OR (sender_id = :seller AND receiver_id = :buyer)",
                                 buyer: current_user.id,
                                 seller: listing.user_id
                               )
                               .first

    if conversation.nil?
      conversation = Conversation.new(
        sender_id: current_user.id,
        receiver_id: listing.user_id,
        listing_id: listing.id
      )

      unless conversation.save
        redirect_to listing_path(listing), alert: "Failed to start conversation"
        return
      end
    end

    # Create the first message
    message = conversation.messages.create!(
      user_id: current_user.id,
      content: params[:message_content]
    )

    redirect_to chat_path(conversation)
  end
end
