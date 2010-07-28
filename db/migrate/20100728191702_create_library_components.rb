class CreateLibraryComponents < ActiveRecord::Migration
  def self.up
    create_table :library_components do |t|
      t.references :library, :null => false
      t.references :component_library, :null => false

      t.timestamps :null => false
    end

    add_index :library_components, :library_id
    add_index :library_components, :component_library_id
    add_index :library_components, [:library_id, :component_library_id], :unique => true
  end

  def self.down
    drop_table :library_components
  end
end
