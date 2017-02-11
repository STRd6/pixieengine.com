class ApplicationMailer < ActionMailer::Base
  default from: 'Pixie <notifications@pixieengine.com>'
  layout 'mailer'

  after_action :check_email, except: [:welcome_email, :forgot_password, :invitation]

private
  def check_email
    if @user
      mail.perform_deliveries = @user.should_receive_email?
    else
      recipient = mail.to[0]
      mail.perform_deliveries = !Email.where(undeliverable: true).find_by_email(recipient)
    end
  end
end
