class AddCompletedToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :completed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :projects, :completed
  end
end
