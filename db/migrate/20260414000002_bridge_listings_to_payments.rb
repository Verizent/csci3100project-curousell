class BridgeListingsToPayments < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :orders, :products
    rename_column :orders, :product_id, :listing_id
    add_foreign_key :orders, :listings

    drop_table :products
  end

  def down
    remove_foreign_key :orders, :listings

    create_table :products do |t|
      t.string   :category
      t.string   :condition,  null: false, default: "good"
      t.string   :currency,   null: false, default: "hkd"
      t.text     :description
      t.integer  :price_cents, null: false, default: 0
      t.bigint   :seller_id,  null: false
      t.string   :status,     null: false, default: "available"
      t.string   :title,      null: false, default: ""
      t.timestamps
    end

    rename_column :orders, :listing_id, :product_id
    add_foreign_key :orders, :products
  end
end
