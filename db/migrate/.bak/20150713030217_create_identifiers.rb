class CreateIdentifiers < ActiveRecord::Migration
  def change
    create_table :identifiers do |t|
      t.references :share, index: true, foreign_key: true
      t.string :name
      t.string :provider

      t.timestamps null: false
    end
  end
end
