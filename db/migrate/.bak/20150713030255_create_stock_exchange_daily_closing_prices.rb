class CreateStockExchangeDailyClosingPrices < ActiveRecord::Migration
  def change
    create_table :stock_exchange_daily_closing_prices do |t|
      t.references :stockExchange, index: true, foreign_key: true
      t.decimal :price
      t.date :when

      t.timestamps null: false
    end
  end
end
