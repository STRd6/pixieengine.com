email_config_path = File.join(Rails.root, "config", "dev_email.yml")

if File.exists? email_config_path
  EMAIL_CONFIG = HashWithIndifferentAccess.new YAML.load_file(email_config_path) if File.exists? email_config_path
else
  EMAIL_CONFIG = { :user_name => "fake", :password => "abc123" }
end

PixieStrd6Com::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => "localhost:3000" }

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "pixieengine.com",
    :user_name => EMAIL_CONFIG[:user_name],
    :password => EMAIL_CONFIG[:password],
    :authentication => "plain",
    :enable_starttls_auto => true
  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
end
