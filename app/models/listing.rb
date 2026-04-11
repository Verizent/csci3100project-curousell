class Listing < ApplicationRecord
  belongs_to :user
<<<<<<< HEAD
<<<<<<< HEAD
  has_one_attached :image
=======
  has_many_attached :images
>>>>>>> 0d3d52e20be76d8ca17664397d339a678223cbe1
=======
  has_many_attached :images
>>>>>>> 9774978a7dd147065d2cee03b5e0ad87716e0744
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
    "Faculty of Social Science" => [
      "Department of Economics",
      "Department of Government and Public Administration",
      "Department of Psychology",
      "Department of Social Work",
      "Department of Sociology"
    ]
  }.freeze

  VALID_FACULTIES    = FACULTY_DEPARTMENTS.keys.freeze
  VALID_DEPARTMENTS  = FACULTY_DEPARTMENTS.values.flatten.freeze

  validates :title,    presence: true, length: { maximum: 100 }
  validates :price,    presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status,   inclusion: { in: STATUSES }
  validate  :faculty_values_are_valid
  validate  :department_values_are_valid

  private

  def faculty_values_are_valid
    invalid = faculty.reject { |f| VALID_FACULTIES.include?(f) }
    errors.add(:faculty, "contains invalid values: #{invalid.join(', ')}") if invalid.any?
  end

  def department_values_are_valid
    invalid = department.reject { |d| VALID_DEPARTMENTS.include?(d) }
    errors.add(:department, "contains invalid values: #{invalid.join(', ')}") if invalid.any?
  end

  public

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
