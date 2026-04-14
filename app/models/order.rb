class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :listing

  STATUSES = %w[pending paid completed cancelled failed refunded].freeze

  validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :pending,   -> { where(status: "pending") }
  scope :paid,      -> { where(status: "paid") }
  scope :completed, -> { where(status: "completed") }

  def amount
    amount_cents / 100.0
  end

  def seller
    listing.user
  end

  def buyer_confirmed?
    buyer_confirmed_at.present?
  end

  def seller_confirmed?
    seller_confirmed_at.present?
  end

  def mark_paid!(payment_intent_id:)
    update!(status: "paid", stripe_payment_intent_id: payment_intent_id)
    AutoCancelOrderJob.set(wait: 2.weeks).perform_later(id)
  end

  def confirm_by_buyer!
    return if buyer_confirmed?
    update!(buyer_confirmed_at: Time.current)
    complete_if_both_confirmed!
  end

  def confirm_by_seller!
    return if seller_confirmed?
    update!(seller_confirmed_at: Time.current)
    complete_if_both_confirmed!
  end

  def mark_failed!
    update!(status: "failed")
    listing.update!(status: "unsold") if listing.status == "in_process"
  end

  def auto_cancel!
    return unless status == "paid"
    update!(status: "refunded")
    listing.update!(status: "unsold")
    Stripe::Refund.create(payment_intent: stripe_payment_intent_id) if stripe_payment_intent_id.present?
  rescue Stripe::StripeError
    # Refund failed on Stripe side — status still updated locally
  end

  private

  def complete_if_both_confirmed!
    return unless buyer_confirmed? && seller_confirmed?
    update!(status: "completed")
    listing.update!(status: "sold")
  end
end
