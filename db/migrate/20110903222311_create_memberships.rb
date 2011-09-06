class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :user, :null => :false
      t.references :group, :polymorphic => true, :null => false

      t.timestamps :null => false
    end

    add_index :memberships, :user_id
    add_index :memberships, [:group_id, :group_type]
    add_index :memberships, [:group_id, :group_type, :user_id], :unique => true

  end
end
