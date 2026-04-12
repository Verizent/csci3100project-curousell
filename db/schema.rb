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

ActiveRecord::Schema[8.1].define(version: 2026_04_12_053442) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "listing_id", null: false
    t.bigint "receiver_id"
    t.bigint "sender_id"
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
    t.index ["receiver_id"], name: "index_conversations_on_receiver_id"
    t.index ["sender_id", "receiver_id", "listing_id"], name: "idx_on_sender_id_receiver_id_listing_id_b8539bcf80", unique: true
    t.index ["sender_id", "receiver_id", "listing_id"], name: "index_conversations_on_sender_receiver_listing", unique: true
    t.index ["sender_id"], name: "index_conversations_on_sender_id"
  end

  create_table "listing_access_rules", force: :cascade do |t|
    t.string "colleges", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.string "departments", default: [], null: false, array: true
    t.string "faculties", default: [], null: false, array: true
    t.bigint "listing_id", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_listing_access_rules_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.string "category", default: "miscellaneous", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "location"
    t.boolean "negotiable", default: false, null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.string "status", default: "unsold", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category"], name: "index_listings_on_category"
    t.index ["created_at"], name: "index_listings_on_created_at"
    t.index ["description"], name: "listings_description_trgm_idx", opclass: :gin_trgm_ops, using: :gin
    t.index ["status"], name: "index_listings_on_status"
    t.index ["title"], name: "listings_title_trgm_idx", opclass: :gin_trgm_ops, using: :gin
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "conversation_id"
    t.datetime "created_at", null: false
    t.boolean "read", default: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "buyer_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "listing_id", null: false
    t.text "notes"
    t.decimal "price_at_purchase", precision: 10, scale: 2
    t.datetime "purchased_at"
    t.integer "seller_id", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["buyer_id", "status"], name: "index_orders_on_buyer_id_and_status"
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["listing_id", "status"], name: "index_orders_on_listing_id_and_status"
    t.index ["listing_id"], name: "index_orders_on_listing_id"
    t.index ["seller_id", "status"], name: "index_orders_on_seller_id_and_status"
    t.index ["seller_id"], name: "index_orders_on_seller_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "listings"
  add_foreign_key "conversations", "users", column: "receiver_id"
  add_foreign_key "conversations", "users", column: "sender_id"
  add_foreign_key "listing_access_rules", "listings"
  add_foreign_key "listings", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "orders", "listings"
end
