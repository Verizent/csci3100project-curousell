class AddConfirmationsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :buyer_confirmed_at, :datetime
    add_column :orders, :seller_confirmed_at, :datetime
  end
end
