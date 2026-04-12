class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :product

  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending paid failed cancelled] }

  scope :pending, -> { where(status: "pending") }
  scope :paid, -> { where(status: "paid") }

  def amount
    amount_cents / 100.0
  end

  def mark_paid!(payment_intent_id:)
    update!(status: "paid", stripe_payment_intent_id: payment_intent_id)
    product.sold!
  end

  def mark_failed!
    update!(status: "failed")
  end
end
