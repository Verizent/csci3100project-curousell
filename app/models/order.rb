class Order < ApplicationRecord
  belongs_to :listing
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'

  validates :status, inclusion: { in: %w[pending completed cancelled refunded] }
  validates :price_at_purchase, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :bought_by, ->(user) { where(buyer_id: user.id) }
  scope :sold_by, ->(user) { where(seller_id: user.id) }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  
  before_validation :set_price_at_purchase, on: :create

  def set_price_at_purchase
    self.price_at_purchase = listing.price if price_at_purchase.nil?
  end

  def complete!
    update(status: 'completed', completed_at: Time.current)
    listing.update(status: 'sold')
  end

  def cancel!
    update(status: 'cancelled')
    listing.update(status: 'unsold') if listing.status == 'in_process'
  end
end
