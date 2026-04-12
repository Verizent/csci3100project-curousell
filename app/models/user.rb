class User < ApplicationRecord
  # Run before saving to database
  has_secure_password
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[^@]+@(\w+\.)*cuhk\.edu\.hk\z/i, message: "must be a CUHK email address" }
  validates :college, presence: true
  validates :faculty, presence: true
  validates :department, presence: true
  validates :password, length: { minimum: 12 }, allow_nil: true

  # Associations for Chat
  has_many :sent_conversations, class_name: "Conversation", foreign_key: "sender_id", dependent: :destroy
  has_many :received_conversations, class_name: "Conversation", foreign_key: "receiver_id", dependent: :destroy
  has_many :messages, dependent: :destroy

  # All conversations (sent or received)
  def all_conversations
    Conversation.where("sender_id = ? OR receiver_id = ?", id, id)
  end

  # Class Constants
  OTP_EXPIRY_MINUTES = 10
  MAX_OTP_ATTEMPTS = 3

  # Class Methods
  def generate_otp!
    raw_code = SecureRandom.random_number(10**6).to_s.rjust(6, "0")
    # Update User's OTP info
    update!(otp_code: raw_code, otp_sent_at: Time.current, otp_attempts: 0)
    raw_code
  end

  def otp_valid?(submitted_code)
    return false if otp_code.blank? || otp_sent_at.blank?
    return false if otp_sent_at < OTP_EXPIRY_MINUTES.minutes.ago
    otp_code == submitted_code.to_s.strip
  end

  def verified?
    verified_at.present?
  end
end
