class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: "hkd"
      t.string :condition, null: false
      t.string :category
      t.string :status, null: false, default: "available"
      t.timestamps
    end

    add_index :products, :status
    add_index :products, :category
  end
end
