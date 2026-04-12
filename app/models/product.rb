class Product < ApplicationRecord
  belongs_to :seller, class_name: "User"
  has_many :orders, dependent: :restrict_with_error

  validates :title, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :condition, presence: true, inclusion: { in: %w[new like_new good fair poor] }
  validates :status, presence: true, inclusion: { in: %w[available sold reserved] }

  scope :available, -> { where(status: "available") }

  def price
    price_cents / 100.0
  end

  def price=(value)
    self.price_cents = (value.to_f * 100).round
  end

  def sold!
    update!(status: "sold")
  end
end
