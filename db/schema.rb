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

ActiveRecord::Schema[7.0].define(version: 2023_11_16_145329) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_bookmarks_on_product_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.integer "parent_comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_comments_on_product_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id", "follower_id"], name: "index_follows_on_followed_id_and_follower_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "products_count", default: 0
    t.integer "position"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "message"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "recipient_id", null: false
    t.bigint "actor_id", null: false
    t.string "action"
    t.bigint "comment_id"
    t.bigint "bookmark_id"
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["bookmark_id"], name: "index_notifications_on_bookmark_id"
    t.index ["comment_id"], name: "index_notifications_on_comment_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "title"
    t.float "price"
    t.text "review"
    t.text "description"
    t.bigint "list_id", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duplicated_count", default: 0
    t.integer "comments_count", default: 0
    t.integer "bookmarks_count", default: 0
    t.integer "photos_count", default: 0
    t.integer "price_cents"
    t.string "price_currency", default: "USD", null: false
    t.string "subscription_type"
    t.integer "position"
    t.index ["list_id"], name: "index_products_on_list_id"
  end

  create_table "referrals", force: :cascade do |t|
    t.string "code"
    t.text "details"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.bigint "list_id"
    t.index ["list_id"], name: "index_referrals_on_list_id"
    t.index ["product_id"], name: "index_referrals_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.text "intro"
    t.integer "followers_count", default: 0
    t.string "privacy", default: "public"
    t.text "bio"
    t.boolean "is_creator", default: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookmarks", "products"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "comments", "products"
  add_foreign_key "comments", "users"
  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "lists", "users"
  add_foreign_key "notifications", "bookmarks"
  add_foreign_key "notifications", "comments"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "products", "lists"
  add_foreign_key "referrals", "lists"
  add_foreign_key "referrals", "products"
end
