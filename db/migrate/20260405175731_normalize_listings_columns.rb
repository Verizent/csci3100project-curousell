class NormalizeListingsColumns < ActiveRecord::Migration[8.1]
  def up
    # Clear seeded data — will be re-seeded after migration
    execute "TRUNCATE TABLE listings, conversations RESTART IDENTITY CASCADE"

    # Convert integer enum columns to human-readable strings
    execute "ALTER TABLE listings ALTER COLUMN category TYPE varchar USING 'miscellaneous'"
    change_column_default :listings, :category, "miscellaneous"

    execute "ALTER TABLE listings ALTER COLUMN status TYPE varchar USING 'unsold'"
    change_column_default :listings, :status, "unsold"

    # College field for scoping listings to a college
    add_column :listings, :college, :string

    # Useful indexes
    add_index :listings, :category
    add_index :listings, :status
    add_index :listings, :college
    add_index :listings, :created_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
