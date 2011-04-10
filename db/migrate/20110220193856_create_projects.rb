class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.references :user, :null => false
      t.string :remote_origin
      t.string :title, :null => false
      t.text :description

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :projects
  end
end
