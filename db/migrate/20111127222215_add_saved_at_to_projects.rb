class AddSavedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :saved_at, :datetime
  end
end
