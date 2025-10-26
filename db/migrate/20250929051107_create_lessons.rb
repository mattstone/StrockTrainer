class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.string :title
      t.text :content
      t.text :prerequisites
      t.integer :xp_reward
      t.integer :unlock_level
      t.integer :position
      t.boolean :published

      t.timestamps
    end
  end
end
