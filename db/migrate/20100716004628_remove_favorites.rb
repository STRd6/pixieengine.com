class RemoveFavorites < ActiveRecord::Migration
  def self.up
    drop_table :favorites
  end

  def self.down
    create_table "favorites", :force => true do |t|
      t.integer  "user_id"
      t.integer  "sprite_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
