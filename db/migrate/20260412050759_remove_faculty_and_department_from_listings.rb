class RemoveFacultyAndDepartmentFromListings < ActiveRecord::Migration[8.1]
  def change
    remove_column :listings, :faculty,    :string, array: true, null: false, default: []
    remove_column :listings, :department, :string, array: true, null: false, default: []
  end
end
