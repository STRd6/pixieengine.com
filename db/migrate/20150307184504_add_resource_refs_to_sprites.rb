class AddResourceRefsToSprites < ActiveRecord::Migration
  def change
    add_column :sprites, :sprite_ref, :string
    add_column :sprites, :thumb_ref, :string
    add_column :sprites, :replay_ref, :string
  end
end
