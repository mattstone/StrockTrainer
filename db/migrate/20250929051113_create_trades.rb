class CreateTrades < ActiveRecord::Migration[8.0]
  def change
    create_table :trades do |t|
      t.references :user, null: false, foreign_key: true
      t.string :symbol
      t.decimal :entry_price, precision: 10, scale: 2
      t.decimal :exit_price, precision: 10, scale: 2
      t.decimal :stop_loss, precision: 10, scale: 2
      t.decimal :position_size, precision: 10, scale: 2
      t.integer :quantity
      t.decimal :pnl, precision: 10, scale: 2
      t.string :status
      t.datetime :entry_date
      t.datetime :exit_date
      t.references :lesson, null: true, foreign_key: true
      t.text :market_view

      t.timestamps
    end
    add_index :trades, :symbol
    add_index :trades, :status
    add_index :trades, [:user_id, :created_at]
  end
end
