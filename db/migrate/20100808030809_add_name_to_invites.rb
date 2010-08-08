class AddNameToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :to, :string, :null => false
  end

  def self.down
    remove_column :invites, :to
  end
end
