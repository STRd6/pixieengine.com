class AddCommenteeToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :commentee_id, :integer

    add_index :comments, :commentee_id

    Comment.reset_column_information

    Comment.all.each do |comment|
      if comment.commentable
        comment.commentee_id = comment.commentable.user_id
        comment.save
      else
        comment.destroy
      end
    end
  end

  def self.down
    remove_column :comments, :commentee_id
  end
end
