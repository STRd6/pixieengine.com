class CreateCollectionItems < ActiveRecord::Migration
  def self.up
    create_table :collection_items do |t|
      t.references :collection, :null => false
      t.references :item, :polymorphic => true, :null => false

      t.timestamps :null => false
    end

    add_index :collection_items, :collection_id
    add_index :collection_items, [:item_id, :item_type]
  end

  def self.down
    drop_table :collection_items
  end
end
