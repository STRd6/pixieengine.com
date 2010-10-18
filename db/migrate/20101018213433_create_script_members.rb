class CreateScriptMembers < ActiveRecord::Migration
  def self.up
    create_table :script_members do |t|
      t.references :script, :null => false
      t.references :user, :null => false

      t.timestamps :null => false
    end

    add_index :script_members, :script_id
    add_index :script_members, :user_id
    add_index :script_members, [:script_id, :user_id], :unique => true
  end

  def self.down
    drop_table :script_members
  end
end
