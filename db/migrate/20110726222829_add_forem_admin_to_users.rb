class AddForemAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :forem_admin, :boolean, :null => false, :default => false
  end
end
