class RemoveUnusedAnimationColumns < ActiveRecord::Migration
  def self.up
    remove_column :animations, :frames
    remove_column :animations, :speed
    remove_column :animations, :frame_width
    remove_column :animations, :frame_height

    add_column :animations, :states, :int
  end

  def self.down
    add_column :animations, :frames, :integer
    add_column :animations, :speed, :integer
    add_column :animations, :frame_width, :integer
    add_column :animations, :frame_height, :integer

    remove_column :animations, :states
  end
end