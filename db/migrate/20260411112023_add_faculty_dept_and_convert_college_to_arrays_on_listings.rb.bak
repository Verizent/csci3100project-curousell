class AddFacultyDeptAndConvertCollegeToArraysOnListings < ActiveRecord::Migration[8.1]
  def up
    # Convert college varchar → varchar[]
    execute "ALTER TABLE listings ALTER COLUMN college TYPE varchar[] USING CASE WHEN college IS NULL THEN '{}' ELSE ARRAY[college] END"
    change_column_default :listings, :college, []

    # Convert faculty varchar → varchar[]
    execute "ALTER TABLE listings ALTER COLUMN faculty TYPE varchar[] USING CASE WHEN faculty IS NULL THEN '{}' ELSE ARRAY[faculty] END"
    change_column_default :listings, :faculty, []

    # Add department as varchar[]
    add_column :listings, :department, :string, array: true, default: []
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
