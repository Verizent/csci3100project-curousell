class AddNegotiableToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :negotiable, :boolean, default: false, null: false
  end
end
