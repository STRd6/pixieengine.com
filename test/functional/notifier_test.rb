require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  setup do
    @user = User.create!(:email => "test@strd6.com", :display_name => "Testman")
  end

  test "comment" do
    @commenter = User.create!(:email => "test3@strd6.com", :display_name => "Commenter")
    @commentee = User.create!(:email => "test2@strd6.com", :display_name => "Commentee")
    @comment = Comment.create!(:commenter => @commenter, :commentee => @commentee)

    mail = Notifier.comment(@comment)
    assert_equal "Commentee, Commenter has commented on your Pixie item.", mail.subject
    assert_equal ["notifications@strd6.com"], mail.from
  end

  test "analytics" do
    mail = Notifier.analytics(@user)
    assert_equal "Weekly Analytics", mail.subject
    assert_equal ["notifications@strd6.com"], mail.from
  end

end
