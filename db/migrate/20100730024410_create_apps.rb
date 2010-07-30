class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|
      t.references :user, :null => false
      t.string :title, :null => false
      t.text :description
      t.text :html
      t.text :code
      t.text :test
      t.references :parent

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :apps
  end
end
