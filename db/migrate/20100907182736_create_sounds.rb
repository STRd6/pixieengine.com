class CreateSounds < ActiveRecord::Migration
  def self.up
    create_table :sounds do |t|
      t.string :title
      t.text :description
      t.references :user

      t.string :wav_file_name
      t.string :wav_content_type
      t.integer :wav_file_size
      t.datetime :wav_uploaded_at

      t.string :sfs_file_name
      t.string :sfs_content_type
      t.integer :sfs_file_size
      t.datetime :sfs_uploaded_at

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :sounds
  end
end
