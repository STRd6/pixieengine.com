class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name, :null => false
    end

    create_table :taggings do |t|
      t.references :tag, :null => false

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, :polymorphic => true, :null => false
      t.references :tagger, :polymorphic => true

      t.string :context, :null => false

      t.datetime :created_at, :null => false
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
