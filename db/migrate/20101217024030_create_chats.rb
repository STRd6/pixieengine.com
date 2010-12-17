class CreateChats < ActiveRecord::Migration
  def self.up
    create_table :chats do |t|
      t.references :user
      t.text :text, :null => false

      t.timestamps :null => false
    end

    add_index :chats, :created_at
  end

  def self.down
    drop_table :chats
  end
end
