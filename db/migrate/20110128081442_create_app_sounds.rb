class CreateAppSounds < ActiveRecord::Migration
  def self.up
    create_table :app_sounds do |t|
      t.references :app, :null => false
      t.references :sound, :null => false
      t.string :name, :null => false

      t.timestamps :null => false
    end

    add_index :app_sounds, :app_id
    add_index :app_sounds, :sound_id
    add_index :app_sounds, [:app_id, :sound_id], :unique => true
    add_index :app_sounds, [:app_id, :name], :unique => true
  end

  def self.down
    drop_table :app_sounds
  end
end
