class AddTestSrcToScripts < ActiveRecord::Migration
  def self.up
    add_column :scripts, :test_src, :text

    Script.all.each do |script|
      if script.lang == "javascript"
        script.update_attribute(:test_src, script.test)
      end
    end
  end

  def self.down
    remove_column :scripts, :test_src
  end
end
