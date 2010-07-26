class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.references :user, :null => false
      t.string :name, :null => false

      t.timestamps :null => false
    end

    add_index :collections, :user_id
  end

  def self.down
    drop_table :collections
  end
end
