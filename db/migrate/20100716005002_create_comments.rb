class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :commenter, :null => false
      t.references :commentable, :null => false, :polymorphic => true
      t.text :body, :null => false

      t.timestamps :null => false
    end

    add_index :comments, :commenter_id
    add_index :comments, [:commentable_id, :commentable_type]

    add_column :collections, :comments_count, :integer, :null => false, :default => 0
    add_column :users, :comments_count, :integer, :null => false, :default => 0
    add_column :sprites, :comments_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :collections, :comments_count
    remove_column :users, :comments_count
    remove_column :sprites, :comments_count

    drop_table :comments
  end
end
