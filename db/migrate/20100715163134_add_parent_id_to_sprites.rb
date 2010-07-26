class AddParentIdToSprites < ActiveRecord::Migration
  def self.up
    add_column :sprites, :parent_id, :integer
  end

  def self.down
    remove_column :sprites, :parent_id
  end
end
