class AddConfirmationsToOrders < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:orders, :buyer_confirmed_at)
      add_column :orders, :buyer_confirmed_at, :datetime
    end
    unless column_exists?(:orders, :seller_confirmed_at)
      add_column :orders, :seller_confirmed_at, :datetime
    end
  end
end
