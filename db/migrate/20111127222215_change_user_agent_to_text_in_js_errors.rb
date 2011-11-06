class ChangeUserAgentToTextInJsErrors < ActiveRecord::Migration
  def up
    change_column :js_errors, :user_agent, :text, :null => false
  end

  def down
    change_column :js_errors, :user_agent, :string, :null => false
  end
end
