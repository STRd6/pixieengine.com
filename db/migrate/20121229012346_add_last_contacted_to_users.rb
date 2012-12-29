class AddLastContactedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_contacted, :datetime, :default => 1.year.ago, :null => false
  end
end
