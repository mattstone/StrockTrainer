class AddMissingColumnsToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :description, :text
    add_column :lessons, :category, :string
    add_column :lessons, :difficulty, :string
    add_column :lessons, :estimated_duration, :integer
    add_column :lessons, :learning_objectives, :text
    add_column :lessons, :practice_trade_enabled, :boolean
  end
end
