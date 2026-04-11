require "rails_helper"

RSpec.describe "Account", type: :request do
  # Prevent real emails and background jobs from firing
  before do
    allow(OtpMailer).to receive(:send_code).and_return(double(deliver_later: true))
    allow(OtpMailer).to receive(:send_2fa).and_return(double(deliver_later: true))
    allow(CleanupUnverifiedUserJob).to receive_message_chain(:set, :perform_later)
  end

  # ---------------------------------------------------------------------------
  # Signup page
  # ---------------------------------------------------------------------------

  describe "GET /account/signup" do
    it "returns 200 and renders the signup form" do
      get account_signup_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Register")
    end
  end

  # ---------------------------------------------------------------------------
  # Create user (POST /account/signup)
  # ---------------------------------------------------------------------------

  describe "POST /account/signup" do
    def valid_signup_params(overrides = {})
      {
        user: {
          name: "Alice Lam",
          email: "alice@link.cuhk.edu.hk",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!",
          college: "Shaw College",
          faculty: [ "Faculty of Engineering" ],
          department: [ "Department of Computer Science and Engineering" ]
        }.merge(overrides),
        terms_accepted: "1"
      }
    end

    context "with valid params and terms accepted" do
      it "creates a new user" do
        expect { post account_signup_path, params: valid_signup_params }
          .to change(User, :count).by(1)
      end

      it "redirects to the OTP verification page" do
        post account_signup_path, params: valid_signup_params
        expect(response).to redirect_to(signup_verify_path)
        follow_redirect!
        expect(response.body).to include("Verify Your Email")
      end

      it "sends an OTP email" do
        expect(OtpMailer).to receive(:send_code)
        post account_signup_path, params: valid_signup_params
      end
    end

    context "without accepting the terms" do
      it "does not create a user" do
        params = valid_signup_params.except(:terms_accepted)
        expect { post account_signup_path, params: params }.not_to change(User, :count)
      end

      it "returns 422 with an error message" do
        params = valid_signup_params.except(:terms_accepted)
        post account_signup_path, params: params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Terms")
      end
    end

    context "with a non-CUHK email" do
      it "does not create a user" do
        params = valid_signup_params(email: "alice@gmail.com")
        expect { post account_signup_path, params: params }.not_to change(User, :count)
      end

      it "returns 422" do
        post account_signup_path, params: valid_signup_params(email: "alice@gmail.com")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with a password shorter than 12 characters" do
      it "does not create a user" do
        params = valid_signup_params(password: "Short1!", password_confirmation: "Short1!")
        expect { post account_signup_path, params: params }.not_to change(User, :count)
      end

      it "returns 422" do
        post account_signup_path, params: valid_signup_params(password: "Short1!", password_confirmation: "Short1!")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with mismatched password confirmation" do
      it "does not create a user" do
        params = valid_signup_params(password_confirmation: "DifferentPass!")
        expect { post account_signup_path, params: params }.not_to change(User, :count)
      end
    end

    context "with a duplicate email" do
      before { create(:user, email: "alice@link.cuhk.edu.hk") }

      it "does not create a second user" do
        expect { post account_signup_path, params: valid_signup_params }
          .not_to change(User, :count)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # OTP verification flow
  # The session is maintained across requests within the same example.
  # ---------------------------------------------------------------------------

  describe "GET /account/verify" do
    it "redirects to signup when there is no pending session" do
      get signup_verify_path
      expect(response).to redirect_to(account_signup_path)
    end

    it "renders the verify page after a successful signup" do
      post account_signup_path, params: {
        user: {
          name: "Bob",
          email: "bob@link.cuhk.edu.hk",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!",
          college: "Shaw College",
          faculty: [ "Faculty of Engineering" ],
          department: [ "Department of Computer Science and Engineering" ]
        },
        terms_accepted: "1"
      }
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Verify Your Email")
    end
  end

  describe "POST /account/verify" do
    def sign_up_carol
      post account_signup_path, params: {
        user: {
          name: "Carol",
          email: "carol@link.cuhk.edu.hk",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!",
          college: "Shaw College",
          faculty: [ "Faculty of Engineering" ],
          department: [ "Department of Computer Science and Engineering" ]
        },
        terms_accepted: "1"
      }
    end

    it "verifies the user and redirects to signin when OTP is correct" do
      sign_up_carol
      user = User.find_by(email: "carol@link.cuhk.edu.hk")
      post signup_verify_path, params: { otp_code: user.otp_code }
      expect(response).to redirect_to(account_signin_path)
      expect(user.reload.verified?).to be true
    end

    it "renders verify with 422 when OTP is wrong" do
      sign_up_carol
      post signup_verify_path, params: { otp_code: "000000" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Incorrect code")
    end

    it "destroys the user and redirects to signup after max failed attempts" do
      sign_up_carol
      user = User.find_by(email: "carol@link.cuhk.edu.hk")
      User::MAX_OTP_ATTEMPTS.times { post signup_verify_path, params: { otp_code: "000000" } }
      expect(User.exists?(user.id)).to be false
      expect(response).to redirect_to(account_signup_path)
    end
  end

  # ---------------------------------------------------------------------------
  # Signin page
  # ---------------------------------------------------------------------------

  describe "GET /account/signin" do
    it "returns 200 and renders the signin form" do
      get account_signin_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign In")
    end
  end

  # ---------------------------------------------------------------------------
  # Authenticate (POST /account/signin)
  # ---------------------------------------------------------------------------

  describe "POST /account/signin" do
    let!(:user) { create(:user) }

    context "with valid credentials for a verified user" do
      it "generates a 2FA OTP and redirects to the 2FA page" do
        expect(OtpMailer).to receive(:send_2fa)
        post account_signin_path, params: { email: user.email, password: "SecurePassword123!" }
        expect(response).to redirect_to(signin_2fa_path)
      end
    end

    context "with a wrong password" do
      it "redirects back to signin with an alert" do
        post account_signin_path, params: { email: user.email, password: "WrongPass!" }
        expect(response).to redirect_to(account_signin_path)
        follow_redirect!
        expect(response.body).to include("Wrong email")
      end
    end

    context "with a non-existent email" do
      it "redirects to signin with an alert" do
        post account_signin_path, params: { email: "nobody@link.cuhk.edu.hk", password: "SecurePassword123!" }
        expect(response).to redirect_to(account_signin_path)
      end
    end

    context "with an unverified account" do
      let!(:unverified) { create(:user, :unverified) }

      it "redirects to the OTP verify page" do
        post account_signin_path, params: { email: unverified.email, password: "SecurePassword123!" }
        expect(response).to redirect_to(signup_verify_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 2FA page
  # ---------------------------------------------------------------------------

  describe "GET /account/2fa" do
    it "redirects to signin when there is no pending 2FA session" do
      get signin_2fa_path
      expect(response).to redirect_to(account_signin_path)
    end

    it "renders the 2FA page after successful signin" do
      user = create(:user)
      post account_signin_path, params: { email: user.email, password: "SecurePassword123!" }
      get signin_2fa_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Verify Your Email")
    end
  end

  # ---------------------------------------------------------------------------
  # Verify 2FA (POST /account/2fa)
  # ---------------------------------------------------------------------------

  describe "POST /account/2fa" do
    let!(:user) { create(:user) }

    before do
      # Trigger signin to establish the pending_2fa_user_id session key
      post account_signin_path, params: { email: user.email, password: "SecurePassword123!" }
    end

    context "with the correct OTP" do
      it "creates a user session and redirects to the home page" do
        code = user.reload.otp_code
        post signin_2fa_path, params: { otp_code: code }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with an incorrect OTP" do
      it "re-renders the 2FA page with 422" do
        post signin_2fa_path, params: { otp_code: "000000" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Incorrect code")
      end

      it "redirects to signin after max failed attempts" do
        User::MAX_OTP_ATTEMPTS.times { post signin_2fa_path, params: { otp_code: "000000" } }
        expect(response).to redirect_to(account_signin_path)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Signout
  # ---------------------------------------------------------------------------

  describe "DELETE /account/signout" do
    it "clears the session and redirects to root" do
      delete account_signout_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("signed out")
    end
  end
end
