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

ActiveRecord::Schema.define(:version => 20130218081610) do

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

  create_table "attachments", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "attachable_id"
    t.string   "attachable_type"
  end

  create_table "banks", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "carts", :force => true do |t|
    t.integer  "items_count"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "shop_id"
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.string   "path"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "imageable_id"
    t.string   "imageable_type"
  end

  create_table "order_transactions", :force => true do |t|
    t.string   "state"
    t.integer  "items_count"
    t.decimal  "total",       :precision => 10, :scale => 0
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "product_items", :force => true do |t|
    t.string   "title"
    t.decimal  "amount",         :precision => 10, :scale => 0
    t.decimal  "price",          :precision => 10, :scale => 0
    t.decimal  "total",          :precision => 10, :scale => 0
    t.integer  "product_id"
    t.integer  "transaction_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
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

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "login"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
