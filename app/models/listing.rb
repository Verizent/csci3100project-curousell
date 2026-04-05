class Listing < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  enum :category, {
    furniture:    0,
    accessories:  1,
    tech:         2,
    books:        3,
    misc:         4
  }

  enum :status, {
    unsold:         0,
    in_transaction: 1,
    sold:           2
  }

  validates :title, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :status, presence: true
end
