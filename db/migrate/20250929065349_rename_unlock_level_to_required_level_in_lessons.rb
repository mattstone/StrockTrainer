class RenameUnlockLevelToRequiredLevelInLessons < ActiveRecord::Migration[8.0]
  def change
    rename_column :lessons, :unlock_level, :required_level
  end
end
