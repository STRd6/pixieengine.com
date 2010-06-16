class CreateSprites < ActiveRecord::Migration
  def self.up
    create_table :sprites do |t|
      t.timestamps :null => false
      t.integer :width, :null => false
      t.integer :height, :null => false
      t.integer :frames, :null => false, :default => 1
      t.references :user
      t.string :title
      t.text :description
    end
  end

  def self.down
    drop_table :sprites
  end
end
