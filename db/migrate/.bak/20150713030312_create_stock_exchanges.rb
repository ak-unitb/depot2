class CreateStockExchanges < ActiveRecord::Migration
  def change
    create_table :stock_exchanges do |t|
      t.string :name
      t.time :closing_time
      t.string :timezone
      t.string :location

      t.timestamps null: false
    end
  end
end
