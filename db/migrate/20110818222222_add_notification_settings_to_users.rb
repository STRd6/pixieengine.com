class AddNotificationSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :forum_notifications, :boolean, :default => true, :null => false
    add_column :users, :site_notifications, :boolean, :default => true, :null => false
  end
end
