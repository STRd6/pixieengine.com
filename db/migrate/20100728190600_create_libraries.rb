class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.references :user
      t.string :title, :null => false
      t.text :description

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :libraries
  end
end
