require "test_helper"

class AccountControllerTest < ActionDispatch::IntegrationTest
  def signup_params
    {
      user: {
        name: "Mike",
        email: "controller_test@link.cuhk.edu.hk",
        college: "C. W. Chu College",
        faculty: [ "Faculty of Engineering" ],
        department: [ "Department of Computer Science and Engineering" ],
        password: "securepassword123",
        password_confirmation: "securepassword123"
      },
      terms_accepted: "1"
    }
  end

  def create_verified_user
    User.create!(
      name: "Verified User",
      email: "verified@link.cuhk.edu.hk",
      college: "C. W. Chu College",
      faculty: [ "Faculty of Engineering" ],
      department: [ "Department of Computer Science and Engineering" ],
      password: "securepassword123",
      password_confirmation: "securepassword123",
      verified_at: Time.current
    )
  end

  # GET /account/signup
  test "get signup page returns success" do
    get account_signup_path
    assert_response :success
  end

  # POST /account/signup
  test "signup with valid params creates user and redirects to verify" do
    assert_difference "User.count", 1 do
      post "/account/signup", params: signup_params
    end
    assert_not_nil User.find_by(email: signup_params[:user][:email]).otp_code
    assert_redirected_to signup_verify_path
  end

  test "signup without accepting terms renders signup" do
    params = signup_params.except(:terms_accepted)
    post "/account/signup", params: params
    assert_nil User.find_by(email: signup_params[:user][:email])
    assert_response :unprocessable_entity
  end

  test "signup with non-CUHK email renders signup" do
    params = signup_params
    params[:user][:email] = "notcuhk@gmail.com"
    post "/account/signup", params: params
    assert_nil User.find_by(email: params[:user][:email])
    assert_response :unprocessable_entity
  end

  test "signup with short password renders signup" do
    params = signup_params
    params[:user][:password] = "short"
    params[:user][:password_confirmation] = "short"
    post "/account/signup", params: params
    assert_nil User.find_by(email: signup_params[:user][:email])
    assert_response :unprocessable_entity
  end

  # GET /account/verify
  test "get verify page without session redirects to signup" do
    get signup_verify_path
    assert_redirected_to account_signup_path
  end

  test "get verify page succeeds after signup" do
    post "/account/signup", params: signup_params
    get signup_verify_path
    assert_response :success
  end

  # POST /account/verify
  test "verify otp with correct code redirects to signin" do
    post "/account/signup", params: signup_params
    user = User.find_by(email: signup_params[:user][:email])
    post "/account/verify", params: { otp_code: user.otp_code }
    assert_redirected_to account_signin_path
  end

  test "verify otp with wrong code renders verify page" do
    post "/account/signup", params: signup_params
    user = User.find_by(email: signup_params[:user][:email])
    wrong_code = user.otp_code == "000000" ? "000001" : "000000"
    post "/account/verify", params: { otp_code: wrong_code }
    assert_response :unprocessable_entity
  end

  test "verify otp destroys user and redirects to signup after max attempts" do
    post "/account/signup", params: signup_params
    user = User.find_by(email: signup_params[:user][:email])
    wrong_code = user.otp_code == "000000" ? "000001" : "000000"
    User::MAX_OTP_ATTEMPTS.times do
      post "/account/verify", params: { otp_code: wrong_code }
    end
    assert_redirected_to account_signup_path
    assert_equal 0, User.where(email: signup_params[:user][:email]).count
  end

  # GET /account/signin
  test "get signin page returns success" do
    get account_signin_path
    assert_response :success
  end

  # POST /account/signin
  test "signin with correct credentials redirects to 2fa" do
    user = create_verified_user
    post "/account/signin", params: { email: user.email, password: "securepassword123" }
    assert_redirected_to signin_2fa_path
  end

  test "signin with wrong password redirects back to signin" do
    user = create_verified_user
    post "/account/signin", params: { email: user.email, password: "wrongpassword123" }
    assert_redirected_to account_signin_path
  end

  test "signin with unverified account redirects to verify" do
    user = User.create!(
      name: "Unverified",
      email: "unverified@link.cuhk.edu.hk",
      college: "C. W. Chu College",
      faculty: [ "Faculty of Engineering" ],
      department: [ "Department of Computer Science and Engineering" ],
      password: "securepassword123",
      password_confirmation: "securepassword123"
    )
    post "/account/signin", params: { email: user.email, password: "securepassword123" }
    assert_redirected_to signup_verify_path
  end

  # GET /account/2fa
  test "get 2fa page without session redirects to signin" do
    get signin_2fa_path
    assert_redirected_to account_signin_path
  end

  test "get 2fa page succeeds after signin" do
    user = create_verified_user
    post "/account/signin", params: { email: user.email, password: "securepassword123" }
    get signin_2fa_path
    assert_response :success
  end

  # POST /account/2fa
  test "verify 2fa with correct code redirects to root" do
    user = create_verified_user
    post "/account/signin", params: { email: user.email, password: "securepassword123" }
    user.reload
    post "/account/2fa", params: { otp_code: user.otp_code }
    assert_redirected_to root_path
  end

  test "verify 2fa with wrong code renders 2fa page" do
    user = create_verified_user
    post "/account/signin", params: { email: user.email, password: "securepassword123" }
    user.reload
    wrong_code = user.otp_code == "000000" ? "000001" : "000000"
    post "/account/2fa", params: { otp_code: wrong_code }
    assert_response :unprocessable_entity
  end

  test "verify 2fa redirects to signin after max attempts" do
    user = create_verified_user
    post "/account/signin", params: { email: user.email, password: "securepassword123" }
    user.reload
    wrong_code = user.otp_code == "000000" ? "000001" : "000000"
    User::MAX_OTP_ATTEMPTS.times do
      post "/account/2fa", params: { otp_code: wrong_code }
    end
    assert_redirected_to account_signin_path
  end
end
