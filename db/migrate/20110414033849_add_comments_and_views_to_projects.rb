class AddCommentsAndViewsToProjects < ActiveRecord::Migration
def self.up
    add_column :projects, :comments_count, :integer, :null => false, :default => 0
    add_column :projects, :views_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :projects, :comments_count
    remove_column :projects, :views_count
  end
end
