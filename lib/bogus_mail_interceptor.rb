class BogusMailInterceptor
  def self.delivering_email(message)
    email = message.to

    if Email.where{:email => email, :undeliverable => true}.any?
      message.perform_deliveries = false
    end
  end
end
