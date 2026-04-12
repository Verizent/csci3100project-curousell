class AddFacultyAndDepartmentToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :faculty,    :string, array: true, null: false, default: [] unless column_exists?(:listings, :faculty)
    add_column :listings, :department, :string, array: true, null: false, default: [] unless column_exists?(:listings, :department)
  end
end
