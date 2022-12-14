ruby '3.1.3'
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 6.1'

gem 'acts-as-taggable-on'
gem 'authlogic'
gem 'aws-sdk-s3'
gem 'coffee-rails'
gem 'dynamic_form'
gem 'exception_notification'
gem 'exception_notification-rake'
gem 'foreman'
gem 'haml-rails'
gem 'mail'
gem 'memoist'
gem 'paperclip'
gem 'pg'
gem 'pg_search'
gem 'public_activity'
gem 'puma'
gem 'rack-cors', :require => 'rack/cors'
gem 'rails_admin'
gem 'redcarpet'
gem 'responders'
gem 'rmagick'
gem 'sanitize'
gem 'sass-rails'
gem 'sidekiq'
gem 'uglifier', '>= 1.3.0'
gem "webrick", "~> 1.7"
gem 'whenever'
gem 'will_paginate'

group :test do
  gem 'factory_girl_rails'
  gem 'mocha', require: false
  gem 'rails-controller-testing'
  gem 'shoulda'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
