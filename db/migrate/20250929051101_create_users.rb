class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.integer :experience_points
      t.integer :level
      t.integer :current_streak
      t.integer :total_trades
      t.integer :profitable_trades

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
