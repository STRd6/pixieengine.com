require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  setup do
    @feedback = Feedback.create(:email_address => "testy@testy.com", :body => "Help I'm A test!")
  end

  test "received_feedback" do
    mail = Notifier.received_feedback(@feedback)
    assert_equal "Received feedback", mail.subject
    assert_equal ["notifications@strd6.com"], mail.from
    assert_equal [@feedback.email_address], mail.reply_to
  end

end
