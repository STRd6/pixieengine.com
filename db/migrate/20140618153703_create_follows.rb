class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows, :id => false do |t|
      t.references :follower, :null => false
      t.references :followee, :null => false

      t.timestamps :null => false
    end
    add_index :follows, :follower_id
    add_index :follows, :followee_id
    add_index :follows, [:follower_id, :followee_id], :unique => true

    add_column :users, :followers_count, :integer, :null => false, :default => 0
    add_column :users, :following_count, :integer, :null => false, :default => 0
  end
end
