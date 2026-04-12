require "rails_helper"

RSpec.describe OtpMailer, type: :mailer do
  let(:user) { build(:user, name: "Alice", email: "alice@link.cuhk.edu.hk") }
  let(:code) { "123456" }

  describe "#send_code" do
    subject(:mail) { OtpMailer.send_code(user, code) }

    it "sends to the user's email" do
      expect(mail.to).to eq([ "alice@link.cuhk.edu.hk" ])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Your verification code for Curousell!")
    end

    it "includes the OTP code in the body" do
      expect(mail.body.encoded).to include(code)
    end

    it "addresses the user by name" do
      expect(mail.body.encoded).to include("Alice")
    end
  end

  describe "#send_2fa" do
    subject(:mail) { OtpMailer.send_2fa(user, code) }

    it "sends to the user's email" do
      expect(mail.to).to eq([ "alice@link.cuhk.edu.hk" ])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Your sign-in code for Curousell!")
    end

    it "includes the OTP code in the body" do
      expect(mail.body.encoded).to include(code)
    end

    it "addresses the user by name" do
      expect(mail.body.encoded).to include("Alice")
    end
  end
end
