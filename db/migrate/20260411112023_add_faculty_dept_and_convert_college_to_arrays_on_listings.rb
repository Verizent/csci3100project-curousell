class AddFacultyDeptAndConvertCollegeToArraysOnListings < ActiveRecord::Migration[8.1]
  def up
    # Convert college varchar → varchar[] if exists
    if column_exists?(:listings, :college)
      execute "ALTER TABLE listings ALTER COLUMN college TYPE varchar[] USING CASE WHEN college IS NULL THEN '{}' ELSE ARRAY[college] END"
      change_column_default :listings, :college, []
    end

    # Convert faculty varchar → varchar[] if exists
    if column_exists?(:listings, :faculty) && columns(:listings).find { |c| c.name == 'faculty' }.type == :string
      execute "ALTER TABLE listings ALTER COLUMN faculty TYPE varchar[] USING CASE WHEN faculty IS NULL THEN '{}' ELSE ARRAY[faculty] END"
      change_column_default :listings, :faculty, []
    end

    # Add department as varchar[] if not exists
    add_column :listings, :department, :string, array: true, default: [] unless column_exists?(:listings, :department)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
