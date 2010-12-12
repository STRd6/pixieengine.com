class DefaultAppHeight < ActiveRecord::Migration
  def self.up
    change_column :apps, :height, :int, :default => 300
  end

  def self.down
    change_column :apps, :height, :int, :default => 320
  end
end
