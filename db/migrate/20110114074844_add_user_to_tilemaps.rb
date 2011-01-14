class AddUserToTilemaps < ActiveRecord::Migration
  def self.up
    add_column :tilemaps, :user_id, :integer
  end

  def self.down
    remove_column :tilemaps, :user_id
  end
end
