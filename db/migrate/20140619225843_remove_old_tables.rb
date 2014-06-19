class RemoveOldTables < ActiveRecord::Migration
  def up
    drop_table :app_libraries
    drop_table :archived_projects
    drop_table :archived_sounds
    drop_table :animations
    drop_table :app_data
    drop_table :app_members
    drop_table :app_sounds
    drop_table :app_sprites
    drop_table :apps
    drop_table :forem_forums
    drop_table :forem_views
    drop_table :forem_posts
    drop_table :forem_topics
    drop_table :libraries
    drop_table :library_components
    drop_table :scripts
    drop_table :user_plugins
    drop_table :tilemaps
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
