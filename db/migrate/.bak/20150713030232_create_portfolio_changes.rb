class CreatePortfolioChanges < ActiveRecord::Migration
  def change
    create_table :portfolio_changes do |t|
      t.references :share, index: true, foreign_key: true
      t.string :transaction_type
      t.integer :quantity
      t.decimal :price_per_share
      t.decimal :total_cost_of_order
      t.date :when

      t.timestamps null: false
    end
  end
end
