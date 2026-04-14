require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) do
    User.create!(
      name: "Test User",
      email: "test@link.cuhk.edu.hk",
      college: "Shaw College",
      faculty: [ "Engineering" ],
      department: [ "Computer Science" ],
      password: "securepassword123",
      password_confirmation: "securepassword123"
    ).tap { |u| u.update!(verified_at: Time.current) }
  end

  let(:valid_token) do
    Rails.application.message_verifier(:user_session).generate(
      { "user_id" => user.id },
      expires_in: ApplicationController::SESSION_EXPIRY
    )
  end

  let(:invalid_token) do
    "invalid.token.here"
  end

  describe '#connect' do
    context 'with a valid user token in cookies' do
      it 'connects and sets current_user' do
        cookies.signed[:user_token] = valid_token

        stub_connection

        connect

        expect(connection.current_user).to eq(user)
      end
    end

    context 'with a valid user token in params' do
      it 'connects and sets current_user' do
        stub_connection

        connect "/cable?user_token=#{CGI.escape(valid_token)}"

        expect(connection.current_user).to eq(user)
      end
    end

    context 'with an invalid token' do
      it 'rejects the connection' do
        cookies.signed[:user_token] = invalid_token

        stub_connection

        expect { connect }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
      end
    end

    context 'with no token' do
      it 'rejects the connection' do
        stub_connection

        expect { connect }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
      end
    end

    context 'with a token for a non-existent user' do
      let(:expired_token) do
        Rails.application.message_verifier(:user_session).generate(
          { "user_id" => 99999 },
          expires_in: ApplicationController::SESSION_EXPIRY
        )
      end
      it 'rejects the connection' do
        cookies.signed[:user_token] = expired_token

        stub_connection

        expect { connect }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
      end
    end
  end
end
