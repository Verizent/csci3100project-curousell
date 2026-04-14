class Listing < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :orders, dependent: :destroy
  has_many :access_rules, class_name: "ListingAccessRule", dependent: :destroy
  accepts_nested_attributes_for :access_rules,
    allow_destroy: true,
    reject_if: ->(attrs) {
      Array(attrs[:colleges]).reject(&:blank?).empty? &&
      Array(attrs[:departments]).reject(&:blank?).empty? &&
      Array(attrs[:faculties]).reject(&:blank?).empty?
    }

  CATEGORIES = %w[furniture accessories tech books clothing miscellaneous].freeze
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
  FACULTY_DEPARTMENTS = {
    "Faculty of Arts" => [
      "Department of Chinese Language and Literature",
      "Department of Cultural and Religious Studies",
      "Department of English",
      "Department of Fine Arts",
      "Department of History",
      "Department of Japanese Studies",
      "Department of Music",
      "Department of Philosophy"
    ],
    "Faculty of Business Administration" => [
      "Department of Accountancy",
      "Department of Decision Sciences and Managerial Economics",
      "Department of Finance",
      "Department of Hotel and Tourism Management",
      "Department of Management",
      "Department of Marketing"
    ],
    "Faculty of Education" => [
      "Department of Curriculum and Instruction",
      "Department of Educational Administration and Policy",
      "Department of Educational Psychology"
    ],
    "Faculty of Engineering" => [
      "Department of Computer Science and Engineering",
      "Department of Electronic Engineering",
      "Department of Information Engineering",
      "Department of Mechanical and Automation Engineering",
      "Department of Systems Engineering and Engineering Management"
    ],
    "Faculty of Law" => [
      "Faculty of Law"
    ],
    "Faculty of Medicine" => [
      "School of Biomedical Sciences",
      "Department of Medicine and Therapeutics",
      "Department of Obstetrics and Gynaecology",
      "Department of Pharmacology",
      "Department of Surgery"
    ],
    "Faculty of Science" => [
      "Department of Biology",
      "Department of Chemistry",
      "Department of Earth and Environmental Sciences",
      "Department of Mathematics",
      "Department of Physics",
      "Department of Statistics"
    ],
    "Faculty of Social Sciences" => [
      "Department of Economics",
      "Department of Government and Public Administration",
      "Department of Psychology",
      "Department of Social Work",
      "Department of Sociology"
    ],
    "Zhizhen School of Interdisciplinary Mathematical Sciences" => [
      "Zhizhen School of Interdisciplinary Mathematical Sciences"
    ],
    "Other Academic Units" => [
      "Postgraduate",
      "Teacher/Lecturer",
      "Researcher",
      "Staff",
      "Other"
    ]
  }.freeze

  validates :title,    presence: true, length: { maximum: 100 }
  validates :price,    presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status,   inclusion: { in: STATUSES }

  scope :available, -> { where(status: "unsold") }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :by_status,   ->(s)   { where(status: s) if s.present? }
  scope :visible_to,  ->(user) {
    no_rules = where(
      "NOT EXISTS (SELECT 1 FROM listing_access_rules WHERE listing_id = listings.id)"
    )
    return no_rules if user.nil?

    no_rules.or(where(
      "EXISTS (
        SELECT 1 FROM listing_access_rules lar
        WHERE lar.listing_id = listings.id
          AND (lar.colleges    = '{}' OR ? = ANY(lar.colleges))
          AND (lar.departments = '{}' OR lar.departments && ARRAY[?]::varchar[])
          AND (lar.faculties   = '{}' OR lar.faculties   && ARRAY[?]::varchar[])
      )",
      user.college.to_s,
      user.department,
      user.faculty
    ))
  }

  def price_cents
    (price * 100).round
  end

  def currency
    "hkd"
  end

  def seller
    user
  end

  def restricted?
    access_rules.loaded? ? access_rules.any? : access_rules.exists?
  end

  def self.search(query)
    return all if query.blank?
    where(
      "word_similarity(:q, title) > 0.55 OR word_similarity(:q, description) > 0.45 " \
      "OR title ILIKE :like OR description ILIKE :like",
      q: query, like: "%#{sanitize_sql_like(query)}%"
    )
  end
end
