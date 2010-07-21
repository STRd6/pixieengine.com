class CreateUserPlugins < ActiveRecord::Migration
  def self.up
    create_table :user_plugins do |t|
      t.references :user, :null => false
      t.references :plugin, :null => false

      t.timestamps :null => false
    end

    add_index :user_plugins, :user_id
    add_index :user_plugins, [:user_id, :plugin_id], :unique => true
  end

  def self.down
    drop_table :user_plugins
  end
end
