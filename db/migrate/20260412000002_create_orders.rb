class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :product, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "hkd"
      t.string :status, null: false, default: "pending"
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.timestamps
    end

    add_index :orders, :stripe_checkout_session_id, unique: true
    add_index :orders, :stripe_payment_intent_id, unique: true
    add_index :orders, :status
  end
end
