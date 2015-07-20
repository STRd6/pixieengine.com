source "https://rubygems.org"

gem 'rails', '3.2.11'

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'coffee-script-source', '~> 1.2.0'
  gem 'compass-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'turbo-sprockets-rails3'
end

group :production do
  gem 'unicorn'
end

gem 'acts-as-taggable-on'
gem "authlogic"
gem "aws-sdk"
gem 'backbone-source'
gem 'bluecloth'
gem 'bootstrap-sass', '~> 2.0.4.0'
gem "coffee-filter"
gem 'cornerstone-source'
gem 'dynamic_form'
gem 'editor_base', :git => "git://github.com/PixieEngine/EditorBase.git"
gem "exception_notification", :git => "git://github.com/rails/exception_notification.git", :require => 'exception_notifier'
gem 'haml'
gem 'haml_coffee_assets'
gem 'html5-boilerplate'
gem 'jquery-image_reader'
gem 'mail'
gem "mocha"
gem 'paperclip', '~> 3.4.0'
gem "pg"
gem 'pixel_editor', :git => 'git://github.com/PixieEngine/PixelEditor.git'
gem "pixie_sass", :git => "git://github.com/PixieEngine/pixie_sass"
gem "public_activity"
gem 'rabl'
gem 'rack-cors', :require => 'rack/cors'
gem 'rails_autolink'
gem "require"
# TODO: Delegate image processing to external service
gem 'rmagick', :require => 'RMagick'
gem "squeel"
gem "sanitize"

gem "execjs"

gem 'underscore-source'
gem "will_paginate", '3.0.3'
gem "whenever"

group :test do
  gem "factory_girl", :git => "git://github.com/thoughtbot/factory_girl.git"
  gem "minitest"
  gem "pry"
  gem "shoulda"
  gem "test-unit"
  gem "turn", :require => false
end

group :development do
  gem "capistrano",
    require: false
  gem 'capistrano-rails',
    require: false
  gem 'capistrano-bundler',
    require: false
  gem 'capistrano-rvm',
    require: false
end

group :development, :test do
  gem 'growl'
  #gem "jasmine"
  #gem 'jasmine-headless-webkit'
  #gem 'jasmine-spec-extras'
  gem 'rb-fsevent'
end
