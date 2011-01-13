class CreateMapTiles < ActiveRecord::Migration
  def self.up
    create_table :map_tiles do |t|
      t.references :tilemap, :null => false
      t.integer :index, :null => false
      t.references :sprite
      t.text :url

      t.timestamps :null => false
    end

    add_index :map_tiles, [:tilemap_id, :index], :unique => true
  end

  def self.down
    drop_table :map_tiles
  end
end
