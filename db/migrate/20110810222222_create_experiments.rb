class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name, :null => false

      t.timestamps :null => false
      t.datetime :ended_at
    end

    add_index :experiments, :name, :unique => true

    create_table :treatments do |t|
      t.references :experiment, :null => false
      t.references :user
      t.string :session_id, :limit => 32
      t.boolean :control, :null => false

      t.timestamps :null => false
    end

    add_index :treatments, [:experiment_id, :user_id], :unique => true
    add_index :treatments, [:experiment_id, :session_id], :unique => true
  end
end
