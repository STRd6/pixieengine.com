class AddUnsubscribedToEmails < ActiveRecord::Migration[5.0]
  def change
    add_column :emails, :unsubscribed, :boolean, null: false, default: false
  end
end
