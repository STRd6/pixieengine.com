class AddSavedAtToArchivedProjects < ActiveRecord::Migration
  def change
    add_column :archived_projects, :saved_at, :datetime
  end
end
