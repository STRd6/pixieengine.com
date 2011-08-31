source 'http://rubygems.org'

gem 'rails', '3.1.0.rc8'

group :assets do
  gem 'sass-rails', "~> 3.1.0.rc"
  gem 'coffee-rails', "~> 3.1.0.rc"
  gem 'uglifier'
  gem 'compass', :git => 'git://github.com/chriseppstein/compass.git', :branch => 'rails31'
end

group :production do
  gem 'unicorn'
end

gem 'acts-as-taggable-on'
gem "authlogic", :git => "git://github.com/odorcicd/authlogic.git", :branch => "rails3"
gem "aws-s3", :require => "aws/s3"
gem "capistrano"
gem "coffee-filter"
gem "delayed_job", "2.1.4"
gem "exception_notification", :git => "git://github.com/rails/exception_notification.git", :require => 'exception_notifier'
gem 'forem', :git => "git://github.com/radar/forem.git"
gem 'gratr', :git => "git://github.com/jdleesmiller/gratr.git"
gem 'haml'
gem 'hpricot'
gem 'html5-boilerplate'
gem 'json'
gem 'mail'
gem "mocha"
gem 'paperclip'
gem "pg"
gem 'rails_autolink'
gem "require"
gem 'rmagick', :require => 'RMagick'
gem "ruport"
gem "sanitize"
gem 'therubyracer'
gem "will_paginate", :git => "git://github.com/akitaonrails/will_paginate.git", :branch => "rails3.1"
gem "whenever"

# Bundle gems for certain environments:
# gem 'rspec', :group => :test
group :test do
  gem "factory_girl"
  gem "shoulda"
  gem "turn", :require => false
end
