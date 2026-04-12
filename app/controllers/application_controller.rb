class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in? 

  SESSION_EXPIRY = 8.hours

  def current_user
    return @current_user if defined?(@current_user)

    token = session[:user_token]
    return @current_user = nil if token.blank?

    payload = Rails.application.message_verifier(:user_session).verified(token)
    user_id = payload && (payload[:user_id] || payload["user_id"])
    @current_user = user_id ? User.find_by(id: user_id) : nil
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    @current_user = nil
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to account_signin_path, alert: "Please log in to continue."
    end
  end

  def authenticate_user!
    require_login
  end
end
