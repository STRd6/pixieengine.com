class CreatePlugins < ActiveRecord::Migration
  def self.up
    create_table :plugins do |t|
      t.references :user
      t.boolean :approved, :null => false, :default => false
      t.string :plugin_type, :null => false
      t.string :title, :null => false
      t.text :description
      t.text :code, :null => false

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :plugins
  end
end
