class AddReplayToSprites < ActiveRecord::Migration
  def self.up
    add_column :sprites, :replayable, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :sprites, :replayable
  end
end
