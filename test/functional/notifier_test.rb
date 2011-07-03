require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  setup do
    @user = User.create!(:email => "test@strd6.com", :display_name => "Testman", :password => "abc123")
  end

  test "comment" do
    @sprite = Factory(:sprite)
    @commenter = User.create!(:email => "test3@strd6.com", :display_name => "Commenter", :password => "abc123")
    @commentee = User.create!(:email => "test2@strd6.com", :display_name => "Commentee", :password => "abc123")
    @comment = Comment.create!(:commenter => @commenter, :commentee => @commentee, :body => "This is a test comment", :commentable => @sprite)

    mail = Notifier.comment(@comment)
    assert_equal "#{@commentee.display_name}, #{@commenter.display_name} has commented on your Pixie item.", mail.subject
    assert_equal ["notifications@strd6.com"], mail.from
  end

  test "analytics" do
    mail = Notifier.analytics(@user)
    assert_equal "Weekly Analytics", mail.subject
    assert_equal ["notifications@strd6.com"], mail.from
  end
end
