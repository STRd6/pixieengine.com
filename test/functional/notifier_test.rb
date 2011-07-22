require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "comment" do
    @comment = Factory :comment

    mail = Notifier.comment(@comment)
    assert_equal "#{@comment.commentee.display_name}, #{@comment.commenter.display_name} has commented on your Pixie item.", mail.subject
  end

  test "analytics" do
    @user = Factory :user

    mail = Notifier.analytics(@user)
    assert_equal "Weekly Analytics", mail.subject
  end
end
