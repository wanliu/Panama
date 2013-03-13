# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130311034002) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "activities", :force => true do |t|
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "addresses", :force => true do |t|
    t.string   "country"
    t.string   "zip_code"
    t.string   "road"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "transaction_id"
    t.integer  "user_id"
    t.integer  "province_id"
    t.integer  "city_id"
    t.integer  "area_id"
    t.integer  "addressable_id"
    t.string   "addressable_type"
  end

  create_table "admin_users", :force => true do |t|
    t.string   "uid"
    t.string   "login"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "admin_users", ["login"], :name => "index_admin_users_on_login", :unique => true

  create_table "attachments", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "file"
  end

  create_table "attachments_products", :force => true do |t|
    t.integer  "attachment_id"
    t.integer  "product_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "banks", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "carts", :force => true do |t|
    t.integer  "items_count", :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "user_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "ancestry"
    t.string   "cover"
    t.integer  "ancestry_depth", :default => 0
  end

  add_index "categories", ["ancestry"], :name => "index_categories_on_ancestry"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "ancestry"
  end

  create_table "comments", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "targeable_id"
    t.string   "targeable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "contents", :force => true do |t|
    t.string   "name"
    t.string   "template"
    t.boolean  "lock"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "shop_id"
  end

  create_table "file_entities", :force => true do |t|
    t.string   "name"
    t.string   "stat"
    t.integer  "size"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "ancestry"
  end

  create_table "images", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "imageable_id"
    t.string   "imageable_type"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "mentionable_user_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "read",                :default => false
    t.string   "url"
    t.text     "body"
  end

  create_table "order_transactions", :force => true do |t|
    t.string   "state"
    t.integer  "items_count"
    t.decimal  "total",       :precision => 10, :scale => 0
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "address_id"
  end

  create_table "product_items", :force => true do |t|
    t.string   "title"
    t.decimal  "amount",         :precision => 10, :scale => 0
    t.decimal  "price",          :precision => 10, :scale => 0
    t.decimal  "total",          :precision => 10, :scale => 0
    t.integer  "transaction_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "cart_id"
    t.integer  "sub_product_id"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.decimal  "price",                 :precision => 10, :scale => 0
    t.string   "summary"
    t.text     "description"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "shop_id"
    t.integer  "category_id"
    t.integer  "default_attachment_id"
    t.integer  "shops_category_id"
  end

  create_table "replies", :force => true do |t|
    t.integer  "comment_id"
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "resources", :force => true do |t|
    t.string   "name"
    t.text     "data"
    t.integer  "content_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shop_groups", :force => true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "shop_user_groups", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shop_group_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "shop_user_id"
  end

  create_table "shop_users", :force => true do |t|
    t.integer  "shop_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "photo"
    t.integer  "user_id"
  end

  create_table "shops_categories", :force => true do |t|
    t.string   "name"
    t.string   "cover"
    t.integer  "shop_id"
    t.string   "ancestry"
    t.integer  "ancestry_depth"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "shops_employee_users", :force => true do |t|
    t.integer  "shop_id"
    t.integer  "employee_user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "style_groups", :force => true do |t|
    t.string   "name"
    t.integer  "product_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "style_items", :force => true do |t|
    t.string   "title"
    t.string   "value"
    t.boolean  "checked",        :default => false
    t.integer  "style_group_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "style_pairs", :force => true do |t|
    t.integer "style_item_id",  :null => false
    t.integer "sub_product_id", :null => false
  end

  create_table "sub_products", :force => true do |t|
    t.float    "price"
    t.float    "quantity"
    t.integer  "product_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "login"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "email"
  end

end
