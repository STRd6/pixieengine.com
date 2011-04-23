class RenameCompletedToArcade < ActiveRecord::Migration
  def self.up
    rename_column :projects, :completed, :arcade
  end

  def self.down
    rename_column :projects, :arcade, :completed
  end
end
