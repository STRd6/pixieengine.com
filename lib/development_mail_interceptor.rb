class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = "#{EMAIL_CONFIG[:user_name]}@gmail.com"
  end
end
