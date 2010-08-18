class CreateVisits < ActiveRecord::Migration
  def self.up
    create_table :visits do |t|
      t.references :user, :null => false
      t.string :controller, :null => false
      t.string :action, :null => false
      t.datetime :created_at, :null => false
    end

    add_index :visits, :user_id
  end

  def self.down
    drop_table :visits
  end
end
