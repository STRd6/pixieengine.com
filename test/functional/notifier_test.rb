require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  setup do
    @feedback = Feedback.create(:email_address => "testy@testy.com", :body => "Help I'm A test!")
    @user = User.create(:email => "test@strd6.com", :display_name => "Testman")
  end

  test "received_feedback" do
    mail = Notifier.received_feedback(@feedback)
    assert_equal "Received feedback", mail.subject
    assert_equal ["notifications@strd6.com"], mail.from
    assert_equal [@feedback.email_address], mail.reply_to
  end

  test "analytics" do
    mail = Notifier.analytics(@user)
    assert_equal "Weekly Analytics", mail.subject
    assert_equal ["notifications@strd6.com"], mail.from
  end

end
