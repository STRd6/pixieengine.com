class AddReferrerIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :referrer_id, :integer
  end

  def self.down
    remove_column :users, :referrer_id
  end
end
