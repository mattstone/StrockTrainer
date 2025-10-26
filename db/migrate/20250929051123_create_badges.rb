class CreateBadges < ActiveRecord::Migration[8.0]
  def change
    create_table :badges do |t|
      t.string :name
      t.text :description
      t.string :icon_class
      t.text :criteria
      t.integer :points_required

      t.timestamps
    end
  end
end
