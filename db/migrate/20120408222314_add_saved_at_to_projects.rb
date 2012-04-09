class AddSavedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :saved_at, :datetime, :null => false, :default => Time.new(2012, 4, 8)
  end
end
