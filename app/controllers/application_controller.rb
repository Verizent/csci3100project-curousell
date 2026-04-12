class ApplicationController < ActionController::Base
  helper_method :current_user
  
  private
  
  def current_user
    # Temporary: Return the first user for testing
    @current_user ||= User.first
  end
  
  def require_login
    return true # for testing purposes, remove this line in production
    unless logged_in?
      redirect_to account_signin_path, alert: "Please log in to continue."
    end
  end

  def authenticate_user!
    require_login
  end
end
