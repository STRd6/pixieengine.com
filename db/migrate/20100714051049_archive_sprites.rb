class ArchiveSprites < ActiveRecord::Migration
  def self.up
    ActsAsArchive.update Sprite
  end

  def self.down
    ActsAsArchive.update Sprite
  end
end
