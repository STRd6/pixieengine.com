class CreateAppMembers < ActiveRecord::Migration
  def self.up
    create_table :app_members do |t|
      t.references :app, :null => false
      t.references :user, :null => false

      t.timestamps :null => false
    end

    add_index :app_members, :app_id
    add_index :app_members, :user_id
    add_index :app_members, [:app_id, :user_id], :unique => true
  end

  def self.down
    drop_table :app_members
  end
end
