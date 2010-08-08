class Notifier < ActionMailer::Base
  default_url_options[:host] = "pixie.strd6.com"

  default :from => "notifications@strd6.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifier.received_feedback.subject
  #
  def received_feedback(feedback)
    @feedback = feedback

    mail :to => "yahivin@gmail.com", :reply_to => feedback.email_address || (feedback.user ? feedback.user.email : nil)
  end

  def welcome_email(user)
    @user = user
    mail :to => user.email
  end

  def invitation(invite)
    @invite = invite
    mail :to => invite.email
  end

  def forgot_password(user)
    @user = user
    mail :to => user.email
  end
end
