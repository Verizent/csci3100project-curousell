class Order < ApplicationRecord
  belongs_to :listing
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  validates :status, inclusion: { in: %w[pending completed cancelled refunded] }
  validates :price_at_purchase, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :bought_by, ->(user) { where(buyer_id: user.id) }
  scope :sold_by,   ->(user) { where(seller_id: user.id) }
  scope :completed, -> { where(status: "completed") }
  scope :pending,   -> { where(status: "pending") }
  scope :expired,   -> { pending.where("purchased_at < ?", 2.weeks.ago) }

  before_validation :set_price_at_purchase, on: :create
  after_create :mark_listing_in_process

  def set_price_at_purchase
    self.price_at_purchase = listing.price if price_at_purchase.nil?
  end

  def mark_listing_in_process
    listing.update(status: "in_process")
  end

  def buyer_confirm!
    update(buyer_confirmed_at: Time.current)
    complete_if_both_confirmed
  end

  def seller_confirm!
    update(seller_confirmed_at: Time.current)
    complete_if_both_confirmed
  end

  def complete_if_both_confirmed
    if buyer_confirmed_at.present? && seller_confirmed_at.present?
      complete!
    end
  end

  def complete!
    update(status: "completed", completed_at: Time.current)
    listing.update(status: "sold")
  end

  def confirmed_by?(user)
    if user == buyer
      buyer_confirmed_at.present?
    elsif user == seller
      seller_confirmed_at.present?
    else
      false
    end
  end

  def cancel!
    update(status: "cancelled")
    listing.update(status: "unsold") if listing.status == "in_process"
  end

  def self.cancel_expired!
    expired.includes(:listing).find_each { |order| order.cancel! }
  end
end
