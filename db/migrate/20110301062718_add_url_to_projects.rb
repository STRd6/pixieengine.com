class AddUrlToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :url, :string

    add_index :projects, :url
  end

  def self.down
    remove_column :projects, :url
  end
end
