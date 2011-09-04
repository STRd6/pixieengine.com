require "#{File.dirname(__FILE__)}/lib/require"

Require do
  
  gem(:rake, '=0.8.7') { require 'rake' }
  gem(:rspec, '=1.3.0')
  
  gemspec do
    author 'Winton Welsh'
    email 'mail@wintoni.us'
    name 'require'
    homepage "http://github.com/winton/#{name}"
    summary "Manage your project's dependencies with a pretty DSL"
    version '0.2.7'
  end
  
  rakefile do
    gem(:rake) { require 'rake/gempackagetask' }
    gem(:rspec) { require 'spec/rake/spectask' }
    require 'lib/require/tasks'
  end
end