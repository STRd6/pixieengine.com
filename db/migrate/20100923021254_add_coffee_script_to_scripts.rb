class AddCoffeeScriptToScripts < ActiveRecord::Migration
  def self.up
    add_column :scripts, :coffee_script, :text
    add_column :scripts, :lang, :string, :default => "coffeescript"

    Script.all.each do |script|
      script.update_attribute(:lang, "javascript")
    end
  end

  def self.down
    remove_column :scripts, :lang
    remove_column :scripts, :coffee_script
  end
end
