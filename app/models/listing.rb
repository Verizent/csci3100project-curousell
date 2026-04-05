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

  scope :search, ->(query) {
    return all if query.blank?
    where(
      "title % :q OR description % :q OR title ILIKE :like OR description ILIKE :like",
      q: query, like: "%#{sanitize_sql_like(query)}%"
    )
  }

  scope :apply_filter, ->(filter, college) {
    case filter
    when "free"        then where(price: 0)
    when "college"     then joins(:user).where(users: { college: college })
    when "tech"        then tech
    when "furniture"   then furniture
    when "books"       then books
    when "accessories" then accessories
    when "misc"        then misc
    when "under50"     then where("price > 0 AND price <= 50")
    when "under100"    then where("price > 0 AND price <= 100")
    when "new"         then where("listings.created_at >= ?", 7.days.ago)
    else all
    end
  }
end
