class AddSuppressionToSprites < ActiveRecord::Migration[5.0]
  def change
    add_column :sprites, :suppression, :integer, null: false, default: 0
    add_column :sprites, :score, :integer, null: false, default: 0

    add_index :sprites, :created_at
    add_index :sprites, :score
    add_index :sprites, :user_id
  end
end
