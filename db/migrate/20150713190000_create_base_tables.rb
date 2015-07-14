class CreateBaseTables < ActiveRecord::Migration

  def change

    create_table "daily_closing_prices", force: :cascade do |t|
      t.integer  "share_id", null: false
      t.decimal  "price", precision: 8, scale: 2, default: 0.0, null: false
      t.date     "when"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "identifiers", force: :cascade do |t|
      t.integer  "share_id", null: false
      t.string   "name", limit: 255, null: false
      t.string   "provider", limit: 255
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "portfolio_changes", force: :cascade do |t|
      t.integer  "share_id", null: false
      t.string   "transaction_type",    limit: 255
      t.integer  "quantity"
      t.decimal  "price_per_share", precision: 8, scale: 2, default: 0.0, null: false
      t.decimal  "total_cost_of_order", precision: 8, scale: 2, default: 0.0, null: false
      t.date     "when"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "shares", force: :cascade do |t|
      t.string   "isin", limit: 255, null: false
      t.string   "name", limit: 255, null: false
      t.string   "currency", limit: 255, null: false
      t.integer  "stock_exchange_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "stock_exchange_daily_closing_prices", force: :cascade do |t|
      t.integer  "stock_exchange_id", null: false
      t.decimal  "price", precision: 8, scale: 2, default: 0.0, null: false
      t.date     "when"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "stock_exchanges", force: :cascade do |t|
      t.string   "name", limit: 255, null: false
      t.time     "closing_time", null: false
      t.string   "timezone", limit: 255, null: false
      t.string   "location", limit: 255, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "daily_closing_prices", ["share_id"], name: "index_daily_closing_prices_on_share_id", using: :btree
    add_index "identifiers", ["share_id"], name: "index_identifiers_on_share_id", using: :btree
    add_index "portfolio_changes", ["share_id"], name: "index_portfolio_changes_on_share_id", using: :btree
    add_index "shares", ["stock_exchange_id"], name: "index_shares_on_stock_exchange_id", using: :btree
    add_index "stock_exchange_daily_closing_prices", ["stock_exchange_id"], name: "index_stock_exchange_daily_closing_prices_on_stock_exchange_id", using: :btree

    add_foreign_key "daily_closing_prices", "shares"
    add_foreign_key "identifiers", "shares"
    add_foreign_key "portfolio_changes", "shares"
    add_foreign_key "shares", "stock_exchanges"
    add_foreign_key "stock_exchange_daily_closing_prices", "stock_exchanges"

  end

end
