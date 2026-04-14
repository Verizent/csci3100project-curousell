class AddCoordinatesToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :latitude, :decimal, precision: 10, scale: 7
    add_column :listings, :longitude, :decimal, precision: 10, scale: 7
  end
end
