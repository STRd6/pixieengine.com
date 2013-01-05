class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.references :user
      t.string :email, :null => false
      t.boolean :undeliverable, :null => false, :default => false

      t.timestamps :null => false
    end

    add_index :emails, :user_id
    add_index :emails, :email
  end
end
