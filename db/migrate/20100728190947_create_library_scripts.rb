class CreateLibraryScripts < ActiveRecord::Migration
  def self.up
    create_table :library_scripts do |t|
      t.references :library, :null => false
      t.references :script, :null => false

      t.timestamps :null => false
    end

    add_index :library_scripts, :library_id
    add_index :library_scripts, :script_id
    add_index :library_scripts, [:library_id, :script_id], :unique => true
  end

  def self.down
    drop_table :library_scripts
  end
end
