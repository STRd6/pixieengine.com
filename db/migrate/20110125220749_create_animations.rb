class CreateAnimations < ActiveRecord::Migration
  def self.up
    create_table :animations do |t|
      t.integer :user_id, :null => false
      t.string :name, :null => false
      t.integer :frames, :null => false
      t.integer :speed, :null => false, :default => 110
      t.integer :frame_width, :null => false, :default => 32
      t.integer :frame_height, :null => false, :default => 32

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :animations
  end
end
