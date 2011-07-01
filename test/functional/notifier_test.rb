require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  setup do
    @user = User.create(:email => "test@strd6.com", :display_name => "Testman")
  end

  test "analytics" do
    mail = Notifier.analytics(@user)
    assert_equal "Weekly Analytics", mail.subject
    assert_equal ["notifications@strd6.com"], mail.from
  end

end
