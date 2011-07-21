require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  setup do
    @user = Factory :user
  end

  test "comment" do
    @sprite = Factory(:sprite)
    @commenter = Factory :user
    @commentee = Factory :user
    @comment = Comment.create!(:commenter => @commenter, :commentee => @commentee, :body => "This is a test comment", :commentable => @sprite)

    mail = Notifier.comment(@comment)
    assert_equal "#{@commentee.display_name}, #{@commenter.display_name} has commented on your Pixie item.", mail.subject
  end

  test "analytics" do
    mail = Notifier.analytics(@user)
    assert_equal "Weekly Analytics", mail.subject
  end
end
