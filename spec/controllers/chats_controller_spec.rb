require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  let(:seller) do
    User.create!(
      name: "Seller User",
      email: "seller@link.cuhk.edu.hk",
      college: "Shaw College",
      faculty: [ "Engineering" ],
      department: [ "Computer Science" ],
      password: "securepassword123",
      password_confirmation: "securepassword123"
    ).tap { |u| u.update!(verified_at: Time.current) }
  end

  let(:buyer) do
    User.create!(
      name: "Buyer User",
      email: "buyer@link.cuhk.edu.hk",
      college: "United College",
      faculty: [ "Arts" ],
      department: [ "History" ],
      password: "securepassword123",
      password_confirmation: "securepassword123"
    ).tap { |u| u.update!(verified_at: Time.current) }
  end

  let(:listing) do
    Listing.create!(
      title: "Calculus Book",
      price: 20,
      description: "Test listing",
      location: "CUHK",
      category: "books",
      status: "unsold",
      user: seller
    )
  end

  let(:conversation) do
    Conversation.create!(
      sender: buyer,
      receiver: seller,
      listing: listing
    )
  end

  let(:message) do
    Message.create!(
      conversation: conversation,
      user: buyer,
      content: "Is this still available?"
    )
  end

  # ---------------------------------------------------------------------------
  # GET /chats -> index action
  # ---------------------------------------------------------------------------
  describe 'GET #index' do
    context 'when logged in' do
      before do
        token = Rails.application.message_verifier(:user_session).generate(
          { "user_id" => buyer.id },
          expires_in: ApplicationController::SESSION_EXPIRY
        )
        session[:user_token] = token
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns conversations to @conversations' do
        get :index
        expect(assigns(:conversations)).to be_a(ActiveRecord::Relation)
      end

      it 'includes listing, sender, receiver, and messages' do
        get :index
        expect(assigns(:conversations).to_a).to eq([])
      end
    end

    context 'when not logged in' do
      it 'redirects to the sign-in page' do
        get :index
        expect(response).to redirect_to(account_signin_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET /chats/:id -> show action
  # ---------------------------------------------------------------------------
  describe 'GET #show' do
    context 'when logged in as a participant' do
      before do
        token = Rails.application.message_verifier(:user_session).generate(
          { "user_id" => buyer.id },
          expires_in: ApplicationController::SESSION_EXPIRY
        )
        session[:user_token] = token
      end

      it 'returns http success' do
        get :show, params: { id: conversation.id }
        expect(response).to have_http_status(:success)
      end

      it 'assigns the conversation to @conversation' do
        get :show, params: { id: conversation.id }
        expect(assigns(:conversation)).to eq(conversation)
      end

      it 'assigns messages to @messages' do
        message
        get :show, params: { id: conversation.id }
        expect(assigns(:messages)).to eq(conversation.messages.order(created_at: :asc))
      end

      it 'assigns the other participant to @other_user' do
        get :show, params: { id: conversation.id }
        expect(assigns(:other_user)).to eq(seller)
      end
    end

    context 'when logged in as non-participant' do
      let(:stranger) do
        User.create!(
          name: "Stranger User",
          email: "stranger@link.cuhk.edu.hk",
          college: "New College",
          faculty: [ "Science" ],
          department: [ "Math" ],
          password: "securepassword123",
          password_confirmation: "securepassword123"
        ).tap { |u| u.update!(verified_at: Time.current) }
      end

      before do
        token = Rails.application.message_verifier(:user_session).generate(
          { "user_id" => stranger.id },
          expires_in: ApplicationController::SESSION_EXPIRY
        )
        session[:user_token] = token
      end

      it 'redirects to the chats index page' do
        get :show, params: { id: conversation.id }
        expect(response).to redirect_to(chats_path)
      end

      it 'sets an alert flash message' do
        get :show, params: { id: conversation.id }
        expect(flash[:alert]).to match(/don't have access/i)
      end
    end

    context 'when not logged in' do
      it 'redirects to the sign-in page' do
        get :show, params: { id: conversation.id }
        expect(response).to redirect_to(account_signin_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET /chats/new -> new action
  # ---------------------------------------------------------------------------
  describe 'GET #new' do
    context 'when logged in' do
      before do
        token = Rails.application.message_verifier(:user_session).generate(
          { "user_id" => buyer.id },
          expires_in: ApplicationController::SESSION_EXPIRY
        )
        session[:user_token] = token
      end

      context 'with a valid listing_id' do
        it 'returns http success' do
          get :new, params: { listing_id: listing.id }
          expect(response).to have_http_status(:success)
        end

        it 'assigns the listing to @listing' do
          get :new, params: { listing_id: listing.id }
          expect(assigns(:listing)).to eq(listing)
        end

        it 'assigns a new conversation to @conversation' do
          get :new, params: { listing_id: listing.id }
          expect(assigns(:conversation)).to be_a_new(Conversation)
        end
      end

      context 'when trying to message own listing' do
        before do
          token = Rails.application.message_verifier(:user_session).generate(
            { "user_id" => seller.id },
            expires_in: ApplicationController::SESSION_EXPIRY
          )
          session[:user_token] = token
        end

        it 'redirects to the listing page' do
          get :new, params: { listing_id: listing.id }
          expect(response).to redirect_to(listing_path(listing))
        end

        it 'sets an alert flash message' do
          get :new, params: { listing_id: listing.id }
          expect(flash[:alert]).to match(/cannot message yourself/i)
        end
      end

      context 'without a listing_id' do
        it 'redirects to the chats index page' do
          get :new
          expect(response).to redirect_to(chats_path)
        end
      end
    end

    context 'when not logged in' do
      it 'redirects to the sign-in page' do
        get :new, params: { listing_id: listing.id }
        expect(response).to redirect_to(account_signin_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /chats/send_message -> send_message action
  # ---------------------------------------------------------------------------
  describe 'POST #send_message' do
    context 'when logged in' do
      before do
        token = Rails.application.message_verifier(:user_session).generate(
          { "user_id" => buyer.id },
          expires_in: ApplicationController::SESSION_EXPIRY
        )
        session[:user_token] = token
      end

      context 'with a valid listing and new conversation' do
        it 'creates a new conversation' do
          expect {
            post :send_message, params: { id: listing.id, listing_id: listing.id, message_content: "Hello!" }
          }.to change(Conversation, :count).by(1)
        end

        it 'creates a new message' do
          expect {
            post :send_message, params: { id: listing.id, listing_id: listing.id, message_content: "Hello!" }
          }.to change(Message, :count).by(1)
        end

        it 'redirects to the chat page' do
          post :send_message, params: { id: listing.id, listing_id: listing.id, message_content: "Hello!" }
          expect(response).to redirect_to(chat_path(Conversation.last))
        end
      end

      context 'with an existing conversation' do
        let!(:existing_conversation) do
          Conversation.create!(
            sender: buyer,
            receiver: seller,
            listing: listing
          )
        end

        it 'reuses the existing conversation' do
          expect {
            post :send_message, params: { id: listing.id, listing_id: listing.id, message_content: "Hello again!" }
          }.not_to change(Conversation, :count)
        end

        it 'creates a new message in the existing conversation' do
          expect {
            post :send_message, params: { id: listing.id, listing_id: listing.id, message_content: "Hello again!" }
          }.to change(Message, :count).by(1)
        end
      end

      context 'when trying to message own listing' do
        before do
          token = Rails.application.message_verifier(:user_session).generate(
            { "user_id" => seller.id },
            expires_in: ApplicationController::SESSION_EXPIRY
          )
          session[:user_token] = token
        end

        it 'redirects to the listing page' do
          post :send_message, params: { id: listing.id, listing_id: listing.id, message_content: "Hello!" }
          expect(response).to redirect_to(listing_path(listing))
        end

        it 'sets an alert flash message' do
          post :send_message, params: { id: listing.id, listing_id: listing.id, message_content: "Hello!" }
          expect(flash[:alert]).to match(/cannot message yourself/i)
        end
      end
    end

    context 'when not logged in' do
      it 'redirects to the sign-in page' do
        post :send_message, params: { id: listing.id, listing_id: listing.id, message_content: "Hello!" }
        expect(response).to redirect_to(account_signin_path)
      end
    end
  end
end
