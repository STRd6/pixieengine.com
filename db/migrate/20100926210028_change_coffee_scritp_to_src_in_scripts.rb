class ChangeCoffeeScritpToSrcInScripts < ActiveRecord::Migration
  def self.up
    rename_column(:scripts, :coffee_script, :src)

    Script.all.each do |script|
      if script.lang == "javascript"
        script.update_attribute(:src, script.code)
      end
    end
  end

  def self.down
    rename_column(:scripts, :src, :coffee_script)
  end
end
