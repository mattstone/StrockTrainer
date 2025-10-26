class CreateUserLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :user_lessons do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.datetime :completed_at
      t.integer :xp_earned

      t.timestamps
    end
  end
end
