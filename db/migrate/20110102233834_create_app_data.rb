class CreateAppData < ActiveRecord::Migration
  def self.up
    create_table :app_data do |t|
      t.references :app, :null => false
      t.string :name, :null => false
      t.text :json, :null => false

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :app_data
  end
end
