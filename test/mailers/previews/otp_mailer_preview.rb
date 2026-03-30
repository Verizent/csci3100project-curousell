# Preview all emails at http://localhost:3000/rails/mailers/otp_mailer
class OtpMailerPreview < ActionMailer::Preview
  USER = User.new(name: "Mike", email: "1155229669@link.cuhk.edu.hk")
  CODE = "123456"
  
  # Preview this email at http://localhost:3000/rails/mailers/otp_mailer/send_code
  def send_code
    OtpMailer.send_code(USER, CODE)
  end

  # Preview this email at http://localhost:3000/rails/mailers/otp_mailer/send_2fa
  def send_2fa
    OtpMailer.send_2fa(USER, CODE)
  end
end
