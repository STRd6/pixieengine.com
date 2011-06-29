class Notifier < ActionMailer::Base
  default_url_options[:host] = "pixie.strd6.com"

  default :from => 'Pixie <notifications@strd6.com>'

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
    mail :subject => "Welcome to Pixie",
      :to => user.email
  end

  def invitation(invite)
    user = invite.user
    @invite = invite
    mail :subject => "You're invited to join Pixie!",
      :to => invite.email,
      :from => "#{user.display_name} <#{user.email}>"
  end

  def newsletter(user)
    @user = user
    mail :subject => "Pixie Newsletter",
      :to => user.email
  end

  def forgot_password(user)
    @user = user
    mail :to => user.email
  end

  def analytics(user)
    @user = user

    graph_png = File.join(Rails.root, 'graph.png')
    report_html = File.join(Rails.root, 'report.html')

    attachments['graph.png'] = File.read graph_png if File.exist?(graph_png)
    attachments['report.html'] = File.read report_html if File.exist?(report_html)

    mail :subject => "Weekly Analytics", :to => user.email
  end
end
