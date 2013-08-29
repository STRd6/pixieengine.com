Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?

Mail.register_interceptor(BogusMailInterceptor)

if Rails.env.production?
  ActionMailer::Base.smtp_settings = ActionMailer::Base.smtp_settings.merge({
    :password => APP_CONFIG[:mandrill_api_key]
  })
end
