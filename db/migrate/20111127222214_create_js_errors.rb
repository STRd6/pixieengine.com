class CreateJsErrors < ActiveRecord::Migration
  def change
    create_table :js_errors do |t|
      t.string :url, :null => false
      t.integer :line_number, :null => false
      t.string :message, :null => false
      t.string :user_agent, :null => false
      t.references :user
      t.string :session_id, :limit => 32

      t.timestamps :null => false
    end
  end
end
