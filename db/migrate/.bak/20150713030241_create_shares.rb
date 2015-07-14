class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.string :isin
      t.string :name
      t.string :currency
      t.references :stock_exchange, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
