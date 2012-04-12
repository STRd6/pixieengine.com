source 'http://rubygems.org'

gem 'rails', '3.2.3'

group :assets do
  gem 'compass-rails'
  gem 'jquery-tmpl-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier'
end

group :production do
  gem 'unicorn'
end

gem 'acts-as-taggable-on'
gem "authlogic"
gem "aws-s3", :require => "aws/s3"
gem 'bluecloth'
gem 'bone_tree', :git => "git://github.com/mdiebolt/bone_tree.git"
gem "capistrano"
gem "coffee-filter"
gem "corelib", :git => "git://github.com/mdiebolt/corelib.git"
gem "exception_notification", :git => "git://github.com/rails/exception_notification.git", :require => 'exception_notifier'
gem 'gratr', :git => "git://github.com/jdleesmiller/gratr.git"
gem 'haml'
gem 'hpricot'
gem 'html5-boilerplate'
gem 'json'
gem 'mail'
gem "mocha"
gem "oink"
gem 'paperclip'
gem "pg"
gem 'rabl'
gem 'rails_autolink'
gem "require"
gem 'rmagick', :require => 'RMagick'
gem "ruport"
gem "sanitize"
gem 'therubyracer'
gem "will_paginate", '3.0.3'
gem "whenever"

group :test do
  gem "factory_girl", :git => "git://github.com/thoughtbot/factory_girl.git"
  gem "shoulda"
  gem "turn", :require => false
  gem "ruby-prof"
end

group :development, :test do
  gem 'growl'
  gem 'guard-jasmine-headless-webkit', :git => 'git://github.com/johnbintz/guard-jasmine-headless-webkit.git'
  gem "jasmine"
  gem 'jasmine-headless-webkit', :git => 'git://github.com/johnbintz/jasmine-headless-webkit.git', :ref => '724541a2cb3ee7d730dac4eb186b451a510bf11e'
end
