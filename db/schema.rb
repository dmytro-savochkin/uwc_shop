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

ActiveRecord::Schema.define(:version => 20130401132136) do

  create_table "categories", :force => true do |t|
    t.text    "name"
    t.text    "link"
    t.integer "faction_id"
  end

  add_index "categories", ["link"], :name => "index_categories_on_link"

  create_table "factions", :force => true do |t|
    t.text "name"
    t.text "link"
  end

  create_table "group_values", :force => true do |t|
    t.integer "category_id"
    t.integer "group_id"
    t.text    "name"
    t.text    "products"
  end

  add_index "group_values", ["category_id", "group_id", "id"], :name => "index_group_values_on_category_id_and_group_id_and_id"
  add_index "group_values", ["category_id", "group_id"], :name => "index_group_values_on_category_id_and_group_id"
  add_index "group_values", ["category_id"], :name => "index_group_values_on_category_id"

# Could not dump table "groups" because of following StandardError
#   Unknown type 'group_type' for column 'type'

  create_table "products", :force => true do |t|
    t.integer "category_id"
    t.text    "name"
    t.decimal "price",             :precision => 10, :scale => 2
    t.boolean "availability"
    t.text    "link"
    t.text    "photo"
    t.text    "photos"
    t.text    "short_description"
    t.text    "description"
  end

  add_index "products", ["availability"], :name => "index_products_on_availability"
  add_index "products", ["category_id"], :name => "index_products_on_category_id"
  add_index "products", ["price", "availability"], :name => "index_products_on_price_and_availability"
  add_index "products", ["price"], :name => "index_products_on_price"

end
