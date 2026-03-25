class AccountController < ApplicationController
  # GET /account/signup
  def signup
    @user = User.new
  end

  # POST /account/signup
  def create_user
    @user = User.new(signup_params)
    @user.faculty = @user.faculty&.reject(&:blank?)
    @user.department = @user.department&.reject(&:blank?)

    unless params[:terms_accepted].present?
      flash.now[:alert] = "You must accept the Terms & Conditions to register."
      render :signup, status: :unprocessable_entity and return
    end

    if @user.save
      raw_code = @user.generate_otp!
      # OtpMailer.send_code(@user, raw_code).deliver_later
      puts raw_code
      session[:pending_user_id] = @user.id
      redirect_to signup_verify_path, notice: "Check your CUHK email for a 6-digit verification code."
    else
      render :signup, status: :unprocessable_entity
    end
  end

  # GET /account/verify => page to input OTP
  def verify
  end

  # POST /account/verify => verify otp
  def verify_signup_otp
  end

  # GET /account/login
  def login
  end

  # POST /account/login
  def authenticate
  end

  # GET /account/2fa
  def two_factor
  end

  # POST /account/2fa
  def verify_2fa
  end

  private

  def signup_params
    params.require(:user).permit(:name, :email, :college, :password, :password_confirmation, faculty: [], department: [])
  end
end