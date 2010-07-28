class CreateScripts < ActiveRecord::Migration
  def self.up
    create_table :scripts do |t|
      t.references :user
      t.boolean :approved, :default => false, :null => false
      t.string :script_type, :null => false
      t.string :title, :null => false
      t.text :description
      t.text :code, :null => false
      t.text :test
      t.references :parent

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :scripts
  end
end
