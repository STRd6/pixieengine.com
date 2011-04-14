class AddFeaturedToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :tutorial, :boolean, :default => false, :null => false
    add_column :projects, :featured, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :projects, :featured
    remove_column :projects, :tutorial
  end
end
