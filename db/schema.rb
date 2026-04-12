# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_12_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "orders", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.bigint "buyer_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "hkd", null: false
    t.bigint "product_id", null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["stripe_checkout_session_id"], name: "index_orders_on_stripe_checkout_session_id", unique: true
    t.index ["stripe_payment_intent_id"], name: "index_orders_on_stripe_payment_intent_id", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "category"
    t.string "condition", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "hkd", null: false
    t.text "description"
    t.integer "price_cents", null: false
    t.bigint "seller_id", null: false
    t.string "status", default: "available", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_products_on_category"
    t.index ["seller_id"], name: "index_products_on_seller_id"
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "college"
    t.datetime "created_at", null: false
    t.string "department", default: [], array: true
    t.string "email"
    t.string "faculty", default: [], array: true
    t.string "name"
    t.integer "otp_attempts"
    t.string "otp_code"
    t.datetime "otp_sent_at"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users", column: "buyer_id"
  add_foreign_key "products", "users", column: "seller_id"
end
