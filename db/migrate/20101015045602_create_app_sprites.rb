class CreateAppSprites < ActiveRecord::Migration
  def self.up
    create_table :app_sprites do |t|
      t.references :app, :null => false
      t.references :sprite, :null => false

      t.timestamps :null => false
    end

    add_index :app_sprites, :app_id
    add_index :app_sprites, :sprite_id
    add_index :app_sprites, [:app_id, :sprite_id], :unique => true
  end

  def self.down
    drop_table :app_sprites
  end
end
