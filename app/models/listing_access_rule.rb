class ListingAccessRule < ApplicationRecord
  belongs_to :listing

  before_save :compact_arrays

  private

  def compact_arrays
    # remove empty strings
    self.colleges    = colleges.reject(&:blank?)
    self.departments = departments.reject(&:blank?)
    self.faculties   = faculties.reject(&:blank?)
  end
end
