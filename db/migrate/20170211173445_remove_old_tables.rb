class RemoveOldTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :access_tokens
    drop_table :feedbacks
    drop_table :js_errors
    drop_table :treatments
  end
end
