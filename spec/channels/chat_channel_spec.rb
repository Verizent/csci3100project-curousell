require 'rails_helper'

RSpec.describe ChatChannel, type: :channel do
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

  describe '#subscribed' do
    context 'when user is a participant of the conversation' do
      it 'streams from the correct channel' do
        stub_connection current_user: buyer

        subscribe(conversation_id: conversation.id)

        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("chat_#{conversation.id}")
      end
    end

    context 'when user is not a participant of the conversation' do
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

      it 'rejects the subscription' do
        stub_connection current_user: stranger

        subscribe(conversation_id: conversation.id)

        expect(subscription).to be_rejected
      end
    end

    context 'when conversation does not exist' do
      it 'raises an error' do
        stub_connection current_user: buyer

        expect {
          subscribe(conversation_id: 99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#speak' do
    context 'when user is a participant' do
      it 'creates a new message in the conversation' do
        stub_connection current_user: buyer
        subscribe(conversation_id: conversation.id)

        expect {
          perform :speak, message: "Hello!"
        }.to change(Message, :count).by(1)

        message = Message.last
        expect(message.content).to eq("Hello!")
        expect(message.user).to eq(buyer)
        expect(message.conversation).to eq(conversation)
      end
    end

    context 'when user is not a participant' do
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

      it 'rejects the subscription so speak cannot be called' do
        stub_connection current_user: stranger

        subscribe(conversation_id: conversation.id)

        # Subscription should be rejected, preventing speak(message) from being called
        expect(subscription).to be_rejected

        # Cannot perform actions on rejected subscription
        expect {
          perform :speak, message: "Hacker message!"
        }.to raise_error(RuntimeError, /Must be subscribed!/)
      end
    end

    context 'when user is not authenticated' do
      it 'rejects the subscription so speak cannot be called' do
        stub_connection current_user: nil

        subscribe(conversation_id: conversation.id)

        # Subscription should be rejected when current_user is nil
        expect(subscription).to be_rejected
      end
    end
  end

  describe '#unsubscribed' do
    it 'cleans up when channel is unsubscribed' do
      stub_connection current_user: buyer
      subscribe(conversation_id: conversation.id)

      expect {
        unsubscribe
      }.not_to raise_error
    end
  end
end
