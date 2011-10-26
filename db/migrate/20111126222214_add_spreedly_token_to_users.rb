class AddSpreedlyTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :spreedly_token, :string
  end
end
