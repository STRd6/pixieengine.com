class AddSubscribedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :subscribed, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :subscribed
  end
end
