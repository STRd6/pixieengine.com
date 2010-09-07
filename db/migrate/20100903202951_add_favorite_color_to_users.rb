class AddFavoriteColorToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :favorite_color, :string
  end

  def self.down
    remove_column :users, :favorite_color
  end
end
