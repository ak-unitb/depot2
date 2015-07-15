class CreateDailyClosingPrices < ActiveRecord::Migration
  def change
    create_table :daily_closing_prices do |t|
      t.references :share, index: true, foreign_key: true
      t.decimal :price
      t.date :date_of_day

      t.timestamps null: false
    end
  end
end
