class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :sender, foreign_key: { to_table: :users }
      t.references  :receiver, foreign_key: { to_table: :users }
      t.references  :listing, null: false, foreign_key: true #referencing to the item being discussed (the chat is item-dependent)
      t.timestamps
    end

    add_index :conversations, [:sender_id, :receiver_id, :listing_id], unique: true
  end
end
