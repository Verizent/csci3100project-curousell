require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:college) }

    context "email format" do
      it "accepts @cuhk.edu.hk addresses" do
        subject.email = "alice@cuhk.edu.hk"
        expect(subject).to be_valid
      end

      it "accepts @link.cuhk.edu.hk addresses" do
        subject.email = "bob@link.cuhk.edu.hk"
        expect(subject).to be_valid
      end

      it "accepts subdomain @*.cuhk.edu.hk addresses" do
        subject.email = "carol@cs.cuhk.edu.hk"
        expect(subject).to be_valid
      end

      it "rejects non-CUHK addresses" do
        subject.email = "dave@gmail.com"
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include("must be a CUHK email address")
      end

      it "rejects look-alike domains" do
        subject.email = "eve@fake-cuhk.edu.hk"
        expect(subject).not_to be_valid
      end
    end

    context "password length" do
      it "rejects passwords shorter than 12 characters" do
        subject.password = "TooShort1!"
        subject.password_confirmation = "TooShort1!"
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to be_present
      end

      it "accepts passwords of exactly 12 characters" do
        subject.password = "Exactly12Chr"
        subject.password_confirmation = "Exactly12Chr"
        expect(subject).to be_valid
      end

      it "accepts passwords longer than 12 characters" do
        subject.password = "ALongerSecurePassword123!"
        subject.password_confirmation = "ALongerSecurePassword123!"
        expect(subject).to be_valid
      end

      it "allows nil password on existing records (no change)" do
        user = create(:user)
        user.name = "Updated Name"
        expect(user).to be_valid
      end
    end

    context "faculty and department arrays" do
      it "is invalid with an empty faculty array" do
        subject.faculty = []
        expect(subject).not_to be_valid
        expect(subject.errors[:faculty]).to be_present
      end

      it "is invalid with an empty department array" do
        subject.department = []
        expect(subject).not_to be_valid
        expect(subject.errors[:department]).to be_present
      end

      it "is valid with populated faculty and department" do
        expect(subject).to be_valid
      end
    end
  end

  # ---------------------------------------------------------------------------
  # #generate_otp!
  # ---------------------------------------------------------------------------

  describe "#generate_otp!" do
    let(:user) { create(:user) }

    it "returns a 6-digit string" do
      code = user.generate_otp!
      expect(code).to match(/\A\d{6}\z/)
    end

    it "persists otp_code to the database" do
      code = user.generate_otp!
      expect(user.reload.otp_code).to eq(code)
    end

    it "sets otp_sent_at to the current time" do
      freeze_time do
        user.generate_otp!
        expect(user.reload.otp_sent_at).to be_within(1.second).of(Time.current)
      end
    end

    it "resets otp_attempts to 0" do
      user.update!(otp_attempts: 2)
      user.generate_otp!
      expect(user.reload.otp_attempts).to eq(0)
    end

    it "generates a different code each call" do
      codes = Array.new(5) { user.generate_otp! }
      # Very unlikely all 5 are identical
      expect(codes.uniq.size).to be > 1
    end
  end

  # ---------------------------------------------------------------------------
  # #otp_valid?
  # ---------------------------------------------------------------------------

  describe "#otp_valid?" do
    let(:user) { create(:user, :with_otp, otp_code: "654321") }

    it "returns true for the correct code within expiry" do
      expect(user.otp_valid?("654321")).to be true
    end

    it "returns false for an incorrect code" do
      expect(user.otp_valid?("000000")).to be false
    end

    it "returns false when the OTP has expired" do
      user.update!(otp_sent_at: (User::OTP_EXPIRY_MINUTES + 1).minutes.ago)
      expect(user.otp_valid?("654321")).to be false
    end

    it "returns false when otp_code is nil" do
      user.update!(otp_code: nil)
      expect(user.otp_valid?("654321")).to be false
    end

    it "returns false when otp_sent_at is nil" do
      user.update!(otp_sent_at: nil)
      expect(user.otp_valid?("654321")).to be false
    end

    it "strips surrounding whitespace from the submitted code" do
      expect(user.otp_valid?("  654321  ")).to be true
    end

    it "returns false for an OTP exactly at the expiry boundary" do
      user.update!(otp_sent_at: User::OTP_EXPIRY_MINUTES.minutes.ago - 1.second)
      expect(user.otp_valid?("654321")).to be false
    end
  end

  # ---------------------------------------------------------------------------
  # #verified?
  # ---------------------------------------------------------------------------

  describe "#verified?" do
    it "returns true when verified_at is present" do
      user = build(:user, verified_at: Time.current)
      expect(user.verified?).to be true
    end

    it "returns false when verified_at is nil" do
      user = build(:user, :unverified)
      expect(user.verified?).to be false
    end
  end

  # ---------------------------------------------------------------------------
  # Constants
  # ---------------------------------------------------------------------------

  describe "constants" do
    it "defines OTP_EXPIRY_MINUTES as 10" do
      expect(User::OTP_EXPIRY_MINUTES).to eq(10)
    end

    it "defines MAX_OTP_ATTEMPTS as 3" do
      expect(User::MAX_OTP_ATTEMPTS).to eq(3)
    end
  end
end
