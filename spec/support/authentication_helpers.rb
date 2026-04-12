module AuthenticationHelpers
  # Stub current_user for request specs that need an authenticated user.
  # The app uses a signed message-verifier token in session[:user_token]
  # rather than a simple session ID, so direct session injection is not
  # straightforward. Stubbing current_user is the pragmatic alternative.
  def sign_in_as(user)
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end
end
