class ListingAccessRule < ApplicationRecord
  belongs_to :listing

  validate :faculties_are_valid
  validate :departments_are_valid

  before_validation :compact_arrays

  private

  def faculties_are_valid
    invalid = faculties.reject { |f| Listing::FACULTY_DEPARTMENTS.key?(f) }
    errors.add(:faculties, "contains invalid values: #{invalid.join(', ')}") if invalid.any?
  end

  def departments_are_valid
    valid = Listing::FACULTY_DEPARTMENTS.values.flatten
    invalid = departments.reject { |d| valid.include?(d) }
    errors.add(:departments, "contains invalid values: #{invalid.join(', ')}") if invalid.any?
  end

  def compact_arrays
    # remove empty strings
    self.colleges    = colleges.reject(&:blank?)
    self.departments = departments.reject(&:blank?)
    self.faculties   = faculties.reject(&:blank?)
  end
end
