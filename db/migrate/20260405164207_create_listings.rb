class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.string :title
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.string :location
      t.integer :category, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
