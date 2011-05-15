class ArchiveProjects < ActiveRecord::Migration
  def self.up
    ActsAsArchive.update Project
  end

  def self.down
  end
end
