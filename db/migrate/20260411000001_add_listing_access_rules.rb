class AddListingAccessRules < ActiveRecord::Migration[8.1]
  def change
    create_table :listing_access_rules do |t|
      t.bigint  :listing_id,  null: false
      t.string  :colleges,    array: true, null: false, default: []
      t.string  :departments, array: true, null: false, default: []
      t.string  :faculties,   array: true, null: false, default: []
      t.timestamps
    end

    add_foreign_key :listing_access_rules, :listings
    add_index :listing_access_rules, :listing_id

    remove_column :listings, :college, :string
  end
end
