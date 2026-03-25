class OtpMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.otp_mailer.send_code.subject
  #
  def send_code(user, code)
    @user = user
    @code = code

    mail(to: @user.email, subject: "Your verification code for Curousell!")
  end
end
