class AddPayingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :paying, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :paying
  end
end
