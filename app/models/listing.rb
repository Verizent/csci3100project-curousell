class Listing < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  CATEGORIES = %w[furniture accessories tech books miscellaneous].freeze
  STATUSES   = %w[unsold in_process sold].freeze
  COLLEGES   = [
    "Shaw College",
    "United College",
    "New Asia College",
    "Chung Chi College",
    "Morningside College",
    "CW Chu College",
    "S.H. Ho College",
    "Lee Woo Sing College",
    "Wu Yee Sun College"
  ].freeze

  validates :title,    presence: true, length: { maximum: 100 }
  validates :price,    presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status,   inclusion: { in: STATUSES }
  validates :college,  inclusion: { in: COLLEGES }, allow_nil: true

  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :by_status,   ->(s)   { where(status: s) if s.present? }
  scope :visible_to,  ->(college) {
    college.present? ? where(college: [ nil, college ]) : where(college: nil)
  }

  def self.search(query)
    return all if query.blank?
    where(
      "word_similarity(:q, title) > 0.75 OR word_similarity(:q, description) > 0.65 " \
      "OR title ILIKE :like OR description ILIKE :like",
      q: query, like: "%#{sanitize_sql_like(query)}%"
    )
  end
end
