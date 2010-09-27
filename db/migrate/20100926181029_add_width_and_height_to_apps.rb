class AddWidthAndHeightToApps < ActiveRecord::Migration
  def self.up
    add_column :apps, :width, :integer, :default => 480
    add_column :apps, :height, :integer, :default => 320

    # Legacy values
    App.all.each do |app|
      app.update_attribute(:width, 640)
      app.update_attribute(:height, 480)
    end
  end

  def self.down
    remove_column :apps, :height
    remove_column :apps, :width
  end
end
