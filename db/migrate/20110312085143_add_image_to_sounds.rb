class AddImageToSounds < ActiveRecord::Migration
  def self.up
    add_column :sounds, :image_file_name,    :string
    add_column :sounds, :image_content_type, :string
    add_column :sounds, :image_file_size,    :integer
    add_column :sounds, :image_updated_at,   :datetime
  end

  def self.down
    remove_column :sounds, :image_file_name
    remove_column :sounds, :image_content_type
    remove_column :sounds, :image_file_size
    remove_column :sounds, :image_updated_at
  end
end
