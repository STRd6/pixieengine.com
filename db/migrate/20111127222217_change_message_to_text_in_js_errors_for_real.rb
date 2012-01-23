class ChangeMessageToTextInJsErrorsForReal < ActiveRecord::Migration
  def up
    change_column :js_errors, :message, :text, :null => false
  end

  def down
    change_column :js_errors, :message, :string, :null => false
  end
end
