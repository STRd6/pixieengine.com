class AddSessionToVisits < ActiveRecord::Migration
  def self.up
    add_column :visits, :session_id, :string, :limit => 32

    change_column :visits, :user_id, :integer, :null => true
  end

  def self.down
    change_column :visits, :user_id, :integer, :null => false

    remove_column :visits, :session_id
  end
end
