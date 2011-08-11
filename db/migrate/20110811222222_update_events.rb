class UpdateEvents < ActiveRecord::Migration
  def up
    drop_table :events

    create_table :events do |t|
      t.string :name, :null => false
      t.references :user
      t.string :session_id, :limit => 32

      t.timestamps :null => false
    end

    add_index :events, [:name, :user_id, :session_id]
    add_index :events, [:name, :user_id]
    add_index :events, [:name, :session_id]
  end

  def down
    
  end
end
