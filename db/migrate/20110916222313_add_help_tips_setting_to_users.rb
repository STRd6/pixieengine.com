class AddHelpTipsSettingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :help_tips, :boolean, :default => true, :null => false
  end
end
