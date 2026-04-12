module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", "User #{current_user.id}" if current_user
    end

    private

    def find_verified_user
      # Try to get token from cookies first (preferred for WebSocket) 
      # in other words, this is a way to verify that the user sees what they should see
      # 
      token = cookies.signed[:user_token]
      
      # Fallback to URL parameter (for debugging)
      token ||= request.params[:user_token]
      
      # Fallback to session 
      token ||= session[:user_token] if respond_to?(:session)
      
      if token.present?
        begin
          payload = Rails.application.message_verifier(:user_session).verify(token)
          user_id = payload["user_id"] || payload[:user_id]
          user = User.find_by(id: user_id)
          return user if user
        rescue ActiveSupport::MessageVerifier::InvalidSignature => e
          logger.error "Invalid token signature in Action Cable: #{e.message}"
        rescue => e
          logger.error "Error verifying token: #{e.message}"
        end
      end
      
      logger.error "Action Cable connection rejected - no valid user token"
      reject_unauthorized_connection
    end
  end
end