class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.references :user, :null => false
      t.references :target, :polymorphic => true, :null => false
      t.string :token, :limit => 16, :null => false

      t.timestamps :null => false
    end

    add_index :links, :token, :unique => true
  end

  def self.down
    drop_table :links
  end
end
