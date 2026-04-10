require "test_helper"

class OtpMailerTest < ActionMailer::TestCase
  setup do
    @user = User.new(name: "Mike", email: "1155229669@link.cuhk.edu.hk")
    @code = "123456"
  end

  test "send_code" do
    mail = OtpMailer.send_code(@user, @code)
    assert_equal "Your verification code for Curousell!", mail.subject
    assert_equal [ @user.email ], mail.to
    assert_equal [ "verizent.rizz@gmail.com" ], mail.from
    assert_match "Hi #{@user.name}", mail.body.encoded
    assert_match @code, mail.body.encoded
  end

  test "send_2fa" do
    mail = OtpMailer.send_2fa(@user, @code)
    assert_equal "Your sign-in code for Curousell!", mail.subject
    assert_equal [ @user.email ], mail.to
    assert_equal [ "verizent.rizz@gmail.com" ], mail.from
    assert_match "Hi #{@user.name}", mail.body.encoded
    assert_match @code, mail.body.encoded
  end
end
