class ApplicationController < ActionController::Base
  helper_method :current_user
  
  private
  
  def current_user
    # Temporary: Return the first user for testing
    @current_user ||= User.first
  end
  
  def require_login
    unless logged_in?
      redirect_to account_signin_path, alert: "Please log in to continue."
    end
  end
end