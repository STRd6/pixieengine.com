class AddCommentsCountToApps < ActiveRecord::Migration
  def self.up
    add_column :apps, :comments_count, :integer, :null => false, :default => 0
    add_column :apps, :views_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :apps, :comments_count
    remove_column :apps, :views_count
  end
end
