class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.timestamps
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :college
      t.string :faculty, array: true, default: []
      t.string :department, array: true, default: []
      t.string :otp_code
      t.datetime :otp_sent_at
      t.integer :otp_attempts
      t.datetime :verified_at
    end
  end
end
