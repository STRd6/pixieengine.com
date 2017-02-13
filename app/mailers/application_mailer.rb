class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: 'Pixie <notifications@pixieengine.com>'
  layout 'mailer'

  after_action :check_undeliverables
  after_action :check_unsubscribes, except: [:forgot_password]

private
  def check_unsubscribes
    return unless mail.perform_deliveries

    recipient = mail.to[0]
    mail.perform_deliveries = !Email.where(unsubscribed: true).find_by_email(recipient)
  end

  def check_undeliverables
    return unless mail.perform_deliveries

    recipient = mail.to[0]
    mail.perform_deliveries = !Email.where(undeliverable: true).find_by_email(recipient)
  end
end
