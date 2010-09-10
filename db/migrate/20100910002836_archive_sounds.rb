class ArchiveSounds < ActiveRecord::Migration
  def self.up
    ActsAsArchive.update Sound
  end

  def self.down
  end
end
