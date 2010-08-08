class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.references :user, :null => false
      t.string :email, :null => false
      t.string :token, :null => false

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :invites
  end
end
