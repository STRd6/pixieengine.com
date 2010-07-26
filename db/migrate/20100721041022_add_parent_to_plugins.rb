class AddParentToPlugins < ActiveRecord::Migration
  def self.up
    add_column :plugins, :parent_id, :integer
  end

  def self.down
    remove_column :plugins, :parent_id
  end
end
