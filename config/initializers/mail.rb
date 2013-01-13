Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?

Mail.register_interceptor(BogusMailInterceptor)
