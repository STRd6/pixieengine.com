class BackfillActivity < ActiveRecord::Migration
  def up
    Comment.find_each do |comment|
      comment.create_activity :create
    end
  end

  def down
    PublicActivity::Activity.delete_all
  end
end
