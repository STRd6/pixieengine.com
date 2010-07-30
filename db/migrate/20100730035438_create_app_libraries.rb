class CreateAppLibraries < ActiveRecord::Migration
  def self.up
    create_table :app_libraries do |t|
      t.references :app, :null => false
      t.references :library, :null => false

      t.timestamps :null => false
    end

    add_index :app_libraries, :app_id
    add_index :app_libraries, :library_id
    add_index :app_libraries, [:app_id, :library_id], :unique => true
  end

  def self.down
    drop_table :app_libraries
  end
end
