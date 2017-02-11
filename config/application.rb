require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pixie3
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.assets.precompile += %w[screen.css postmaster.js]

    config.middleware.use ExceptionNotification::Rack,
      :email => {
        :email_prefix => "[pixieengine.com] ",
        :sender_address => %{"Notifier" <notifier@pixieengine.com>},
        :exception_recipients => %w[yahivin@gmail.com]
      }

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '/sprites.json', :headers => :any, :methods => [:get, :options]
      end
    end


  end
end
