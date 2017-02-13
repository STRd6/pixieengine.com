# Preview all emails at http://localhost:3000/rails/mailers/notifier
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome_email(User.first)
  end

  def invite
    Notifier.invitation(Invite.first)
  end
end
