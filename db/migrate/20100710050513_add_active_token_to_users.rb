class AddActiveTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :active_token_id, :integer
  end

  def self.down
    remove_column :users, :active_token_id
  end
end
