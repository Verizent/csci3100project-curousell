class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :category, null: false, default: "miscellaneous"
      t.string :location
      t.string :status, null: false, default: "unsold"
      t.string :college
      t.timestamps
    end

    add_index :listings, :category
    add_index :listings, :status
    add_index :listings, :created_at
    add_index :listings, :college
  end
end
