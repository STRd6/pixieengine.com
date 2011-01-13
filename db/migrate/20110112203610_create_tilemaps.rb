class CreateTilemaps < ActiveRecord::Migration
  def self.up
    create_table :tilemaps do |t|
      t.string :title, :null => false
      t.references :parent
      t.integer :width, :null => false
      t.integer :height, :null => false
      t.integer :tile_width, :null => false, :default => 32
      t.integer :tile_height, :null => false, :default => 32

      t.string :data_file_name
      t.string :data_content_type
      t.integer :data_file_size
      t.datetime :data_updated_at

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :tilemaps
  end
end
