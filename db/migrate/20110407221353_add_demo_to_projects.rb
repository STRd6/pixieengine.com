class AddDemoToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :demo, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :projects, :demo
  end
end
