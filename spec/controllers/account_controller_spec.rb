require 'rails_helper'

RSpec.describe AccountController, type: :controller do
  let(:valid_attributes) do
    {
      name: "Test User",
      email: "test@cuhk.edu.hk",
      college: "Shaw College",
      faculty: [ "Engineering" ],
      department: [ "Computer Science" ],
      password: "securepassword123",
      password_confirmation: "securepassword123"
    }
  end

  let(:user) do
    User.create!(valid_attributes)
  end

  let(:verified_user) do
    User.create!(valid_attributes.merge(email: "verified@cuhk.edu.hk")).tap do |u|
      u.update!(verified_at: Time.current)
    end
  end

  before do
    # Prevent real emails from being sent
    allow(OtpMailer).to receive_message_chain(:send_code, :deliver_later)
    allow(OtpMailer).to receive_message_chain(:send_2fa, :deliver_later)
    # Prevent background jobs from running
    allow(CleanupUnverifiedUserJob).to receive_message_chain(:set, :perform_later)
  end

  # ---------------------------------------------------------------------------
  # GET /account/signup
  # ---------------------------------------------------------------------------
  describe 'GET #signup' do
    it 'returns http success' do
      get :signup
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new User to @user' do
      get :signup
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  # ---------------------------------------------------------------------------
  # POST /account/signup (create_user)
  # ---------------------------------------------------------------------------
  describe 'POST #create_user' do
    context 'with valid params and terms accepted' do
      it 'creates a new user' do
        expect {
          post :create_user, params: { user: valid_attributes, terms_accepted: "1" }
        }.to change(User, :count).by(1)
      end

      it 'sends an OTP email' do
        expect(OtpMailer).to receive(:send_code).and_return(double(deliver_later: true))
        post :create_user, params: { user: valid_attributes, terms_accepted: "1" }
      end

      it 'stores the new user id in session' do
        post :create_user, params: { user: valid_attributes, terms_accepted: "1" }
        expect(session[:pending_user_id]).to be_present
      end

      it 'redirects to the verify page' do
        post :create_user, params: { user: valid_attributes, terms_accepted: "1" }
        expect(response).to redirect_to(signup_verify_path)
      end
    end

    context 'without accepting terms' do
      it 'does not create a user' do
        expect {
          post :create_user, params: { user: valid_attributes }
        }.not_to change(User, :count)
      end

      it 're-renders the signup page with an alert' do
        post :create_user, params: { user: valid_attributes }
        expect(response).to render_template(:signup)
        expect(flash[:alert]).to match(/Terms & Conditions/i)
      end

      it 'returns unprocessable entity status' do
        post :create_user, params: { user: valid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid user params' do
      let(:invalid_attributes) { valid_attributes.merge(email: "not-a-cuhk-email@gmail.com") }

      it 'does not create a user' do
        expect {
          post :create_user, params: { user: invalid_attributes, terms_accepted: "1" }
        }.not_to change(User, :count)
      end

      it 're-renders the signup page' do
        post :create_user, params: { user: invalid_attributes, terms_accepted: "1" }
        expect(response).to render_template(:signup)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET /account/verify
  # ---------------------------------------------------------------------------
  describe 'GET #verify' do
    context 'with a valid pending user in session' do
      before { session[:pending_user_id] = user.id }

      it 'returns http success' do
        get :verify
        expect(response).to have_http_status(:success)
      end

      it 'assigns @user from session' do
        get :verify
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'without a pending user in session' do
      it 'redirects to the signup page' do
        get :verify
        expect(response).to redirect_to(account_signup_path)
      end

      it 'sets an alert flash message' do
        get :verify
        expect(flash[:alert]).to match(/Session expired/i)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /account/verify (verify_signup_otp)
  # ---------------------------------------------------------------------------
  describe 'POST #verify_signup_otp' do
    before do
      user.update!(otp_code: "123456", otp_sent_at: Time.current, otp_attempts: 0)
      session[:pending_user_id] = user.id
    end

    context 'with a correct OTP' do
      it 'marks the user as verified' do
        post :verify_signup_otp, params: { otp_code: "123456" }
        expect(user.reload.verified_at).to be_present
      end

      it 'clears the otp_code after verification' do
        post :verify_signup_otp, params: { otp_code: "123456" }
        expect(user.reload.otp_code).to be_nil
      end

      it 'clears the pending_user_id from the session' do
        post :verify_signup_otp, params: { otp_code: "123456" }
        expect(session[:pending_user_id]).to be_nil
      end

      it 'redirects to the signin page' do
        post :verify_signup_otp, params: { otp_code: "123456" }
        expect(response).to redirect_to(account_signin_path)
      end
    end

    context 'with an incorrect OTP' do
      it 'increments otp_attempts' do
        post :verify_signup_otp, params: { otp_code: "000000" }
        expect(user.reload.otp_attempts).to eq(1)
      end

      it 're-renders the verify page' do
        post :verify_signup_otp, params: { otp_code: "000000" }
        expect(response).to render_template(:verify)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'shows remaining attempts in flash' do
        post :verify_signup_otp, params: { otp_code: "000000" }
        expect(flash[:alert]).to match(/attempt/i)
      end
    end

    context 'when max OTP attempts are reached' do
      before { user.update!(otp_attempts: User::MAX_OTP_ATTEMPTS - 1) }

      it 'destroys the user' do
        expect {
          post :verify_signup_otp, params: { otp_code: "000000" }
        }.to change(User, :count).by(-1)
      end

      it 'redirects to the signup page with an alert' do
        post :verify_signup_otp, params: { otp_code: "000000" }
        expect(response).to redirect_to(account_signup_path)
        expect(flash[:alert]).to match(/Maximum attempts/i)
      end
    end

    context 'with no pending user in session' do
      before { session.delete(:pending_user_id) }

      it 'redirects to the signup page' do
        post :verify_signup_otp, params: { otp_code: "123456" }
        expect(response).to redirect_to(account_signup_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET /account/signin
  # ---------------------------------------------------------------------------
  describe 'GET #signin' do
    it 'returns http success' do
      get :signin
      expect(response).to have_http_status(:success)
    end
  end

  # ---------------------------------------------------------------------------
  # POST /account/signin (authenticate)
  # ---------------------------------------------------------------------------
  describe 'POST #authenticate' do
    context 'with wrong credentials' do
      it 'redirects back to signin with an alert' do
        post :authenticate, params: { email: "wrong@cuhk.edu.hk", password: "wrongpassword" }
        expect(response).to redirect_to(account_signin_path)
        expect(flash[:alert]).to match(/Wrong email/i)
      end
    end

    context 'with correct credentials but unverified account' do
      it 'redirects to the verify page with an alert' do
        post :authenticate, params: { email: user.email, password: "securepassword123" }
        expect(response).to redirect_to(signup_verify_path)
        expect(flash[:alert]).to match(/not verified/i)
      end
    end

    context 'with correct credentials and a verified account' do
      it 'sends a 2FA OTP email' do
        expect(OtpMailer).to receive(:send_2fa).and_return(double(deliver_later: true))
        post :authenticate, params: { email: verified_user.email, password: "securepassword123" }
      end

      it 'stores the user id for 2FA in session' do
        post :authenticate, params: { email: verified_user.email, password: "securepassword123" }
        expect(session[:pending_2fa_user_id]).to eq(verified_user.id)
      end

      it 'redirects to the 2FA page' do
        post :authenticate, params: { email: verified_user.email, password: "securepassword123" }
        expect(response).to redirect_to(signin_2fa_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET /account/2fa
  # ---------------------------------------------------------------------------
  describe 'GET #two_factor' do
    context 'with a pending 2FA session' do
      before { session[:pending_2fa_user_id] = verified_user.id }

      it 'returns http success' do
        get :two_factor
        expect(response).to have_http_status(:success)
      end
    end

    context 'without a pending 2FA session' do
      it 'redirects to the signin page' do
        get :two_factor
        expect(response).to redirect_to(account_signin_path)
      end

      it 'sets an alert flash message' do
        get :two_factor
        expect(flash[:alert]).to match(/Please log in/i)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /account/2fa (verify_2fa)
  # ---------------------------------------------------------------------------
  describe 'POST #verify_2fa' do
    before do
      verified_user.update!(otp_code: "654321", otp_sent_at: Time.current, otp_attempts: 0)
      session[:pending_2fa_user_id] = verified_user.id
    end

    context 'with a correct 2FA OTP' do
      it 'clears the 2FA session key' do
        post :verify_2fa, params: { otp_code: "654321" }
        expect(session[:pending_2fa_user_id]).to be_nil
      end

      it 'sets a signed user_token in the session' do
        post :verify_2fa, params: { otp_code: "654321" }
        expect(session[:user_token]).to be_present
      end

      it 'redirects to the root path with a welcome notice' do
        post :verify_2fa, params: { otp_code: "654321" }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to match(/Welcome back/i)
      end
    end

    context 'with an incorrect 2FA OTP' do
      it 'increments otp_attempts' do
        post :verify_2fa, params: { otp_code: "000000" }
        expect(verified_user.reload.otp_attempts).to eq(1)
      end

      it 're-renders the two_factor page' do
        post :verify_2fa, params: { otp_code: "000000" }
        expect(response).to render_template(:two_factor)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'shows remaining attempts in flash' do
        post :verify_2fa, params: { otp_code: "000000" }
        expect(flash[:alert]).to match(/attempt/i)
      end
    end

    context 'when max 2FA attempts are reached' do
      before { verified_user.update!(otp_attempts: User::MAX_OTP_ATTEMPTS - 1) }

      it 'clears the 2FA session key' do
        post :verify_2fa, params: { otp_code: "000000" }
        expect(session[:pending_2fa_user_id]).to be_nil
      end

      it 'redirects to the signin page with an alert' do
        post :verify_2fa, params: { otp_code: "000000" }
        expect(response).to redirect_to(account_signin_path)
        expect(flash[:alert]).to match(/Too many/i)
      end
    end

    context 'with an expired 2FA OTP' do
      before { verified_user.update!(otp_sent_at: (User::OTP_EXPIRY_MINUTES + 1).minutes.ago) }

      it 'clears the 2FA session key' do
        post :verify_2fa, params: { otp_code: "654321" }
        expect(session[:pending_2fa_user_id]).to be_nil
      end

      it 'redirects to the signin page with an expiry alert' do
        post :verify_2fa, params: { otp_code: "654321" }
        expect(response).to redirect_to(account_signin_path)
        expect(flash[:alert]).to match(/expired/i)
      end
    end

    context 'with no matching user in session' do
      before { session[:pending_2fa_user_id] = -1 }

      it 'redirects to the signin page' do
        post :verify_2fa, params: { otp_code: "654321" }
        expect(response).to redirect_to(account_signin_path)
        expect(flash[:alert]).to match(/Session expired/i)
      end
    end
  end
end
