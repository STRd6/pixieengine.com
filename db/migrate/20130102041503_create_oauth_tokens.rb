class CreateOauthTokens < ActiveRecord::Migration
  def change
    create_table :oauth_tokens do |t|
      t.references :user, :null => false
      t.string :provider, :null => false
      t.string :token, :null => false

      t.timestamps :null => false
    end
    add_index :oauth_tokens, :user_id

    User.where{oauth_token != nil}.each do |user|
      user.update_oauth("github", user.oauth_token)
    end

    remove_column :users, :oauth_token
  end
end
