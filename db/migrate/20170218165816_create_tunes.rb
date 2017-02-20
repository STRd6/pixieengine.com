class CreateTunes < ActiveRecord::Migration[5.0]
  def change
    create_table :tunes do |t|
      t.references :user, foreign_key: true
      t.string :title, null: false, default: "Untitled"
      t.text :description, null: false, default: ""
      t.integer :parent_id

      t.string :content_sha256, null: false

      t.json :meta, null: false, default: {}

      t.integer :comments_count, null: false, default: 0
      t.integer :favorites_count, null: false, default: 0

      t.integer :score, null: false, default: 0
      t.integer :suppression, null: false, default: 0

      t.timestamps null: false
    end

    add_index :tunes, :parent_id
    add_index :tunes, :created_at
    add_index :tunes, :score
  end
end
