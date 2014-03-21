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

ActiveRecord::Schema.define(:version => 20140321054925) do

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
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
    t.string   "activity_type",   :limit => 14
    t.string   "description"
    t.integer  "product_id"
    t.decimal  "price",                         :precision => 10, :scale => 2
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "author_id"
    t.integer  "limit_count",     :limit => 8
    t.integer  "like"
    t.integer  "participate"
    t.integer  "shop_product_id"
    t.integer  "shop_id"
    t.integer  "status",                                                       :default => 0
    t.string   "rejected_reason"
    t.string   "title"
  end

  create_table "activities_attachments", :force => true do |t|
    t.integer "attachment_id"
    t.string  "activity_id"
    t.string  "integer"
    t.integer "number"
  end

  create_table "activities_likes", :force => true do |t|
    t.integer "activity_id"
    t.integer "user_id"
  end

  create_table "activities_order_transactions", :force => true do |t|
    t.integer "activity_id"
    t.integer "order_transaction_id"
    t.boolean "state",                :default => false
  end

  create_table "activities_participates", :force => true do |t|
    t.integer "activity_id"
    t.integer "user_id"
  end

  create_table "activity_rules", :force => true do |t|
    t.string   "name",        :limit => 25
    t.string   "value",       :limit => 25
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.integer  "activity_id"
    t.string   "value_type",  :limit => 25
    t.string   "svalue",      :limit => 25
    t.integer  "nvalue"
    t.decimal  "dvalue",                    :precision => 10, :scale => 2
    t.datetime "dtvalue"
  end

  create_table "addresses", :force => true do |t|
    t.string   "zip_code"
    t.string   "road"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "province_id"
    t.integer  "city_id"
    t.integer  "area_id"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.time     "deleted_at"
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

  create_table "answer_ask_buys", :force => true do |t|
    t.integer  "ask_buy_id"
    t.integer  "shop_product_id"
    t.integer  "amount",                                              :default => 0
    t.decimal  "price",                :precision => 10, :scale => 2, :default => 0.0
    t.integer  "user_id"
    t.decimal  "total",                :precision => 10, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.integer  "status",                                              :default => 0
    t.integer  "order_transaction_id"
  end

  create_table "ask_buy_paticipates", :force => true do |t|
    t.integer  "ask_buy_id"
    t.integer  "user_id"
    t.integer  "shop_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ask_buys", :force => true do |t|
    t.integer  "product_id"
    t.string   "title"
    t.decimal  "price",      :precision => 10, :scale => 2, :default => 0.0
    t.integer  "amount",                                    :default => 0
    t.text     "describe"
    t.integer  "status",                                    :default => 0
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "user_id"
    t.boolean  "open",                                      :default => true
  end

  create_table "ask_buys_attachments", :force => true do |t|
    t.integer "ask_buy_id"
    t.integer "attachment_id"
  end

  create_table "attachments", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "file"
  end

  create_table "attachments_chat_messages", :force => true do |t|
    t.integer "chat_message_id"
    t.integer "attachment_id"
  end

  create_table "attachments_products", :force => true do |t|
    t.integer "attachment_id"
    t.integer "product_id"
  end

  create_table "attachments_regions", :force => true do |t|
    t.integer "region_id"
    t.integer "attachment_id"
  end

  create_table "attachments_topics", :force => true do |t|
    t.integer "topic_id"
    t.integer "attachment_id"
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

  create_table "catalogs", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "catalogs_categories", :force => true do |t|
    t.integer "catalog_id"
    t.integer "category_id"
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
    t.integer "category_id"
    t.integer "property_id"
    t.boolean "filter_state", :default => false
  end

  create_table "category_property_values", :force => true do |t|
    t.integer  "category_property_id"
    t.string   "value"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "circle_categories", :force => true do |t|
    t.integer  "circle_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
  end

  create_table "circle_friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "circle_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "identity"
  end

  create_table "circle_settings", :force => true do |t|
    t.boolean  "limit_city", :default => false
    t.boolean  "limit_join", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "circles", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "description"
    t.integer  "city_id"
    t.integer  "setting_id"
    t.integer  "attachment_id"
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

  create_table "community_notifications", :force => true do |t|
    t.boolean  "state",           :default => false
    t.text     "body"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "send_user_id"
    t.integer  "circle_id"
    t.boolean  "apply_state"
    t.integer  "notification_id"
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

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "delivery_addresses", :force => true do |t|
    t.integer  "user_id"
    t.string   "zip_code"
    t.string   "road"
    t.integer  "province_id"
    t.integer  "city_id"
    t.integer  "area_id"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.time     "deleted_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "delivery_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.decimal  "price",       :precision => 4, :scale => 2
  end

  create_table "dialogues", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "direct_transactions", :force => true do |t|
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.decimal  "total",         :precision => 10, :scale => 0
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "state"
    t.integer  "operator_id"
    t.string   "number"
    t.datetime "expired_time"
    t.integer  "address_id"
    t.string   "delivery_code"
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

  add_index "inventory_caches", ["last_time"], :name => "index_inventory_caches_on_last_time"
  add_index "inventory_caches", ["options"], :name => "index_inventory_caches_on_styles"
  add_index "inventory_caches", ["product_id"], :name => "index_inventory_caches_on_product_id"
  add_index "inventory_caches", ["warehouse_id"], :name => "index_inventory_caches_on_warhouse"

  create_table "invite_users", :force => true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.integer  "send_user_id"
    t.string   "targeable_type"
    t.integer  "targeable_id"
    t.boolean  "read",           :default => false
    t.integer  "behavior",       :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
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

  create_table "money_bills", :force => true do |t|
    t.string   "serial_number"
    t.decimal  "money",         :precision => 10, :scale => 2
    t.integer  "user_id"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.boolean  "state",                                        :default => true
    t.integer  "transfer_id"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "mentionable_user_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "read",                :default => false
    t.string   "url"
    t.text     "body"
    t.string   "targeable_type"
    t.integer  "targeable_id"
  end

  create_table "order_reasons", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "order_refund_items", :force => true do |t|
    t.integer  "order_refund_id"
    t.text     "title"
    t.decimal  "amount",          :precision => 10, :scale => 0, :default => 0
    t.decimal  "price",           :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "total",           :precision => 10, :scale => 2, :default => 0.0
    t.integer  "product_id"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.integer  "shop_id"
  end

  create_table "order_refund_state_details", :force => true do |t|
    t.integer  "order_refund_id"
    t.string   "state"
    t.datetime "expired"
    t.boolean  "expired_state",   :default => true
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "order_refunds", :force => true do |t|
    t.integer  "order_reason_id"
    t.text     "decription"
    t.integer  "order_transaction_id"
    t.decimal  "total",                :precision => 10, :scale => 2, :default => 0.0
    t.string   "state"
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.text     "refuse_reason"
    t.integer  "operator_id"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.string   "delivery_code"
    t.decimal  "delivery_price",       :precision => 5,  :scale => 2, :default => 0.0
    t.string   "order_state"
    t.string   "number"
    t.string   "transport_type"
  end

  create_table "order_transactions", :force => true do |t|
    t.string   "state"
    t.integer  "items_count"
    t.decimal  "total",          :precision => 10, :scale => 2
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "address_id"
    t.boolean  "operator_state",                                :default => false
    t.decimal  "delivery_price", :precision => 5,  :scale => 2
    t.integer  "operator_id"
    t.string   "delivery_code"
    t.integer  "pay_status",                                    :default => 0
    t.string   "number"
    t.datetime "dispose_date"
    t.string   "transport_type"
    t.string   "pay_type"
  end

  create_table "permissions", :force => true do |t|
    t.string   "resource"
    t.string   "ability"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "persistent_channels", :force => true do |t|
    t.string   "name",         :limit => 30
    t.integer  "channel_type", :limit => 2
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "user_id"
    t.string   "icon"
  end

  create_table "price_lists", :force => true do |t|
    t.integer  "people_number"
    t.decimal  "price",         :precision => 10, :scale => 0
    t.integer  "activity_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
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

  create_table "product_comments", :force => true do |t|
    t.integer  "product_item_id"
    t.integer  "shop_id"
    t.integer  "user_id"
    t.integer  "star_product"
    t.integer  "star_service"
    t.integer  "star_logistics"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "product_id"
  end

  create_table "product_delivery_types", :force => true do |t|
    t.integer  "product_id"
    t.integer  "delivery_type_id"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.decimal  "delivery_price",   :precision => 5, :scale => 2, :default => 0.0
  end

  create_table "product_items", :force => true do |t|
    t.string   "title"
    t.integer  "amount",                                    :default => 0
    t.decimal  "price",      :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "total",      :precision => 10, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.integer  "cart_id"
    t.integer  "product_id"
    t.string   "options"
    t.integer  "shop_id"
    t.integer  "user_id"
    t.integer  "buy_state"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "product_items", ["options"], :name => "index_product_items_on_options"

  create_table "product_items_properties", :force => true do |t|
    t.integer "product_item_id"
    t.integer "property_id"
  end

  create_table "product_items_property_items", :force => true do |t|
    t.integer "product_item_id"
    t.integer "property_item_id"
    t.string  "title"
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
    t.decimal  "price",                 :precision => 10, :scale => 2
    t.string   "summary"
    t.text     "description"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "shop_id"
    t.integer  "category_id"
    t.integer  "default_attachment_id"
    t.integer  "shops_category_id"
    t.string   "brand_name"
    t.string   "emc13"
    t.integer  "unit_id"
  end

  create_table "products_properties", :force => true do |t|
    t.integer "product_id"
    t.integer "property_id"
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

  create_table "recharges", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "money",      :precision => 10, :scale => 2
    t.integer  "payer"
    t.boolean  "state",                                     :default => false
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  create_table "region_cities", :force => true do |t|
    t.integer  "city_id"
    t.integer  "region_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "advertisement"
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

  create_table "settings", :force => true do |t|
    t.string   "var"
    t.string   "value"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "shop_groups", :force => true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "shop_product_product_items", :force => true do |t|
    t.integer  "shop_product_id"
    t.integer  "product_item_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "shop_product_refund_items", :force => true do |t|
    t.integer  "shop_product_id"
    t.integer  "order_refund_item_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "shop_products", :force => true do |t|
    t.integer  "shop_id"
    t.integer  "product_id"
    t.decimal  "price",             :precision => 10, :scale => 2
    t.decimal  "inventory",         :precision => 10, :scale => 2
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.time     "deleted_at"
    t.decimal  "sales",             :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "returned",          :precision => 10, :scale => 2, :default => 0.0
    t.integer  "inventory_unit_id"
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
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "photo"
    t.integer  "user_id"
    t.string   "im_token"
    t.boolean  "actived",      :default => false
    t.integer  "address_id"
    t.string   "shop_url"
    t.string   "shop_summary"
    t.integer  "audit_count",  :default => 0
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
    t.decimal  "price",      :precision => 10, :scale => 2
    t.decimal  "quantity",   :precision => 10, :scale => 0
    t.integer  "product_id",                                :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "temporary_channels", :force => true do |t|
    t.string   "name",           :limit => 30
    t.integer  "channel_type",   :limit => 2
    t.integer  "user_id"
    t.string   "token",          :limit => 45
    t.integer  "targeable_id"
    t.string   "targeable_type"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "topic_participates", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "topics", :force => true do |t|
    t.integer  "user_id"
    t.string   "content"
    t.string   "content_html"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "category_id"
    t.integer  "circle_id"
    t.integer  "participate",  :default => 0
  end

  create_table "transaction_operators", :force => true do |t|
    t.integer  "order_transaction_id"
    t.integer  "operator_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "transaction_state_details", :force => true do |t|
    t.integer  "order_transaction_id"
    t.string   "state"
    t.datetime "expired"
    t.boolean  "expired_state",        :default => true
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "count",                :default => 0
  end

  create_table "transfer_accounts", :force => true do |t|
    t.string   "name"
    t.string   "number"
    t.integer  "bank_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "transfer_moneys", :force => true do |t|
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "decription"
    t.string   "number"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "user_id"
    t.integer  "pay_type"
    t.integer  "source_id"
    t.string   "source_type"
    t.decimal  "money",       :precision => 10, :scale => 2
  end

  create_table "transfer_sheets", :force => true do |t|
    t.string   "person"
    t.string   "code"
    t.string   "bank"
    t.integer  "order_transaction_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "transfers", :force => true do |t|
    t.string   "targeable_type"
    t.integer  "targeable_id"
    t.decimal  "amount",          :precision => 10, :scale => 2, :default => 0.0
    t.integer  "status"
    t.integer  "shop_product_id"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  create_table "unit_conversions", :force => true do |t|
    t.integer "big_unit_id"
    t.integer "small_unit_id"
    t.float   "percentage",    :default => 1.0
  end

  create_table "units", :force => true do |t|
    t.string  "code"
    t.string  "name"
    t.integer "child_id"
    t.float   "percentage", :default => 1.0
  end

  create_table "user_banks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "bank_id"
    t.string   "code"
    t.string   "name"
    t.boolean  "state",      :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.time     "deleted_at"
  end

  create_table "user_checkings", :force => true do |t|
    t.integer  "user_id"
    t.string   "industry_type"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "company_name"
    t.string   "company_license"
    t.string   "company_license_photo"
    t.string   "ower_name"
    t.string   "ower_photo"
    t.string   "ower_shenfenzheng_number"
    t.string   "phone"
    t.boolean  "products_added",                         :default => false
    t.boolean  "rejected",                               :default => false
    t.string   "rejected_reason"
    t.boolean  "checked",                                :default => false
    t.integer  "rejected_times",                         :default => 0
    t.integer  "address_id"
    t.string   "service",                  :limit => 20
    t.string   "shop_photo"
  end

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "login"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.string   "email"
    t.decimal  "money",                    :precision => 20, :scale => 4, :default => 0.0
    t.string   "im_token"
    t.string   "services",   :limit => 30
  end

  create_table "warehouses", :force => true do |t|
    t.string   "title"
    t.integer  "shop_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "withdraw_moneys", :force => true do |t|
    t.decimal  "money",       :precision => 10, :scale => 2
    t.integer  "bank_id"
    t.integer  "user_id"
    t.integer  "state",                                      :default => 0
    t.integer  "arrive_mode",                                :default => 0
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
  end

end
