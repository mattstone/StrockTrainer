class CreatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios do |t|
      t.references :user, null: false, foreign_key: true
      t.string :portfolio_type
      t.decimal :total_value, precision: 15, scale: 2
      t.decimal :initial_value, precision: 15, scale: 2
      t.decimal :risk_score, precision: 3, scale: 1

      t.timestamps
    end
    add_index :portfolios, [:user_id, :portfolio_type]
  end
end
