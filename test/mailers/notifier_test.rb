require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "invite" do
    invite = build :invite,
      token: SecureRandom.hex(8)
    sender = invite.user
    email = Notifier.invitation(invite).message

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver
    end

    assert_equal [sender.email], email.from
    assert_equal [invite.email], email.to
  end
end
