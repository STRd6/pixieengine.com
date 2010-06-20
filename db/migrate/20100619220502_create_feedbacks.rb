class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.references :user
      t.text :body, :null => false
      t.string :email_address

      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
