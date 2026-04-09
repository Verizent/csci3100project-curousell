class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :listing, null: false, foreign_key: true
      t.integer :buyer_id, null: false
      t.integer :seller_id, null: false
      t.string :status, default: 'pending'
      t.decimal :price_at_purchase, precision: 10, scale: 2
      t.datetime :purchased_at
      t.datetime :completed_at
      t.text :notes

      t.timestamps
    end

    add_index :orders, :buyer_id
    add_index :orders, :seller_id
    add_index :orders, [:buyer_id, :status]
    add_index :orders, [:seller_id, :status]
    add_index :orders, [:listing_id, :status]
  end
end
