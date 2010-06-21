class Notifier < ActionMailer::Base
  default :from => "notifications@strd6.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.notifier.received_feedback.subject
  #
  def received_feedback(feedback)
    @feedback = feedback

    mail :to => "yahivin@gmail.com", :reply_to => feedback.email_address
  end

  def email_password(user)
    @password = user.password

    mail :to => user.email
  end
end
