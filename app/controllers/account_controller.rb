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
      CleanupUnverifiedUserJob.set(wait: User::OTP_EXPIRY_MINUTES.minutes).perform_later(@user.id)
      redirect_to signup_verify_path, notice: "Check your CUHK email for a 6-digit verification code."
    else
      render :signup, status: :unprocessable_entity
    end
  end

  # GET /account/verify => page to input OTP
  def verify
    @user = User.find_by(id: session[:pending_user_id])
    redirect_to account_signup_path, alert: "Session expired. Please sign up again." unless @user
  end

  # POST /account/verify => verify otp
  def verify_signup_otp
    @user = User.find_by(id: session[:pending_user_id])
    unless @user
      redirect_to account_signup_path, alert: "Session expired. Please sign up again." and return
    end

    if @user.otp_valid?(params[:otp_code])
      @user.update!(verified_at: Time.current, otp_code: nil)
      session.delete(:pending_user_id)
      redirect_to account_login_path, notice: "Email verified! You can now log in."
    else
      @user.increment!(:otp_attempts)
      if @user.otp_attempts >= User::MAX_OTP_ATTEMPTS
        session.delete(:pending_user_id)
        @user.destroy
        redirect_to account_signup_path, alert: "Maximum attempts reached. Please sign up again." and return
      end
      remaining = User::MAX_OTP_ATTEMPTS - @user.otp_attempts
      flash.now[:alert] = "Incorrect code. #{remaining} attempt#{'s' if remaining != 1} remaining."
      render :verify, status: :unprocessable_entity
    end
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