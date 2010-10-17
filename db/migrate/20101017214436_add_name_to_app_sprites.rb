class AddNameToAppSprites < ActiveRecord::Migration
  def self.up
    AppSprite.all.each(&:destroy)

    add_column :app_sprites, :name, :string, :null => false

    add_index :app_sprites, [:app_id, :name], :unique => true
  end

  def self.down
    remove_column :app_sprites, :name
  end
end
