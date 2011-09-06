class AddMembershipsCountToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :memberships_count, :integer, :null => false, :default => 0
    add_column :archived_projects, :memberships_count, :integer
  end
end
