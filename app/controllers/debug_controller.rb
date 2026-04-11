class DebugController < ActionController::Base
  layout false
  skip_before_action :verify_authenticity_token

  def session
    # Access request env directly to avoid helper method issues
    session_data = request.env["rack.session"]
    cookie_data = request.cookies

    info = "Session keys: #{session_data&.keys || 'nil'}\n"
    info += "Has session[:user_token]: #{session_data&.dig(:user_token) ? 'yes' : 'no'}\n"
    info += "Has cookie user_token: #{cookie_data['user_token'] ? 'yes' : 'no'}\n"
    info += "All cookies: #{cookie_data.keys.join(', ')}"

    render plain: info
  end
end
