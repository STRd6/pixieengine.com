class AddRootAndRepliesToComments < ActiveRecord::Migration
  def up
    add_column :comments, :root_id, :integer
    add_column :comments, :in_reply_to_id, :integer

    Comment.reset_column_information

    Comment.all.each do |comment|
      comment.root ||= comment

      comment.save
    end
  end

  def down
    remove_column :comments, :root_id
    remove_column :comments, :in_reply_to_id
  end
end
