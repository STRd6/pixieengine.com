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
    should_perform = !Email.where(unsubscribed: true).find_by_email(recipient)
    unless should_perform
      logger.info "Skip sending email to #{recipient} because they are unsubscribed"
    end
    mail.perform_deliveries = should_perform
  end

  def check_undeliverables
    return unless mail.perform_deliveries

    recipient = mail.to[0]
    should_perform = !Email.where(undeliverable: true).find_by_email(recipient)
    unless should_perform
      logger.info "Skip sending email to #{recipient} because they are unsubscribed"
    end
    mail.perform_deliveries = should_perform
  end
end
