class AddSrcToApps < ActiveRecord::Migration
  def self.up
    add_column :apps, :src, :text
    add_column :apps, :lang, :string, :default => "coffeescript"

    App.all.each do |app|
      app.lang = "javascript"
      app.src = app.code
      app.save!
    end
  end

  def self.down
    remove_column :apps, :lang
    remove_column :apps, :src
  end
end
