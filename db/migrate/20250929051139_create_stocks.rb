class CreateStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.string :name
      t.decimal :current_price, precision: 10, scale: 2
      t.datetime :last_updated
      t.string :sector
      t.bigint :market_cap

      t.timestamps
    end
    add_index :stocks, :symbol, unique: true
    add_index :stocks, :sector
  end
end
