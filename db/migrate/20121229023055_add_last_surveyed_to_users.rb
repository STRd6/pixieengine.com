class AddLastSurveyedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_surveyed, :datetime, :default => 3.years.ago, :null => false
  end
end
