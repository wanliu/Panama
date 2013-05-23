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

ActiveRecord::Schema.define(:version => 20130523072714) do

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
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "activity_type", :limit => 14
  end

  create_table "activity_rules", :force => true do |t|
    t.string   "name",        :limit => 25
    t.string   "value",       :limit => 25
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "activity_id"
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

  create_table "admins", :force => true do |t|
    t.string   "uid"
    t.string   "login"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "categories_properties", :force => true do |t|
    t.integer  "category_id"
    t.integer  "property_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "chat_messages", :force => true do |t|
    t.integer  "send_user_id"
    t.integer  "receive_user_id"
    t.text     "content"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "read",            :default => false
  end

  create_table "circle_friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "circle_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "circles", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.text     "content_html"
  end

  create_table "contact_friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.datetime "last_contact_date"
  end

  create_table "contents", :force => true do |t|
    t.string   "name"
    t.string   "template"
    t.boolean  "lock"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "shop_id"
    t.integer  "contentable_id"
    t.string   "contentable_type"
  end

  create_table "credits", :force => true do |t|
    t.integer  "user_id"
    t.integer  "bank_id"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "followings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "follow_id"
    t.string   "follow_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "friend_group_users", :force => true do |t|
    t.integer  "friend_group_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "friend_groups", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "group_permissions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "permission_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "imageable_id"
    t.string   "imageable_type"
  end

  create_table "inventory_caches", :force => true do |t|
    t.integer "product_id"
    t.string  "options"
    t.decimal "count",        :precision => 10, :scale => 0
    t.integer "warehouse_id"
    t.decimal "last_time",    :precision => 20, :scale => 10
  end

  create_table "item_in_outs", :force => true do |t|
    t.integer  "product_id"
    t.integer  "product_item_id"
    t.decimal  "quantity",        :precision => 10, :scale => 0
    t.string   "options"
    t.integer  "warehouse_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
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
    t.integer  "operator_id"
  end

  create_table "permissions", :force => true do |t|
    t.string   "resource"
    t.string   "ability"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "price_options", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "property_id"
    t.integer  "optionable_id"
    t.string   "optionable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "product_items", :force => true do |t|
    t.integer  "transaction_id"
    t.string   "title"
    t.decimal  "amount",         :precision => 10, :scale => 0
    t.decimal  "price",          :precision => 10, :scale => 0
    t.decimal  "total",          :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cart_id"
    t.integer  "product_id"
    t.string   "options"
  end

  add_index "product_items", ["options"], :name => "index_product_items_on_options"

  create_table "product_items_properties", :force => true do |t|
    t.integer  "product_item_id"
    t.integer  "property_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "product_items_property_items", :force => true do |t|
    t.integer  "product_item_id"
    t.integer  "property_item_id"
    t.string   "title"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "product_prices", :force => true do |t|
    t.integer  "product_id"
    t.decimal  "price",      :precision => 10, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "product_prices_property_items", :id => false, :force => true do |t|
    t.integer "product_price_id"
    t.integer "property_item_id"
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

  create_table "products_properties", :force => true do |t|
    t.integer  "product_id"
    t.integer  "property_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "products_property_items", :force => true do |t|
    t.integer "product_id"
    t.integer "property_item_id"
    t.string  "title"
  end

  create_table "properties", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "property_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "property_items", :force => true do |t|
    t.integer  "property_id"
    t.string   "value"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "property_values", :force => true do |t|
    t.integer  "valuable_id"
    t.integer  "property_id"
    t.string   "svalue"
    t.integer  "nvalue"
    t.decimal  "dvalue",        :precision => 20, :scale => 10
    t.datetime "dtvalue"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "valuable_type"
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
    t.integer  "shop_user_id"
    t.integer  "shop_group_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
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

  create_table "topic_attachments", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "attachment_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "topic_categories", :force => true do |t|
    t.string   "name"
    t.integer  "shop_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "topic_receives", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "receive_id"
    t.string   "receive_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "topics", :force => true do |t|
    t.integer  "user_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "content"
    t.string   "content_html"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "status"
    t.integer  "topic_category_id"
  end

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "login"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "email"
    t.decimal  "money",      :precision => 20, :scale => 4
    t.string   "im_token"
  end

  create_table "warehouses", :force => true do |t|
    t.string   "title"
    t.integer  "shop_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
