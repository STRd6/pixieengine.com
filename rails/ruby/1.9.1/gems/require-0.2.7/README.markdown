Require
=======

Manage your project's dependencies with a pretty DSL.

* Gem activation
* Require calls
* Load paths
* Gemspec configuration

Install
-------

<pre>
sudo gem install require
</pre>

Example
-------

Create <code>require.rb</code> in your project's root directory:

<pre>
require 'rubygems'
gem 'require'
require 'require'

Require do

  gem(:sinatra, '=0.9.4') { require 'sinatra/base' }
  gem(:haml, '=2.2.16') { require %w(haml sass) }

  lib do
    gem :sinatra
    gem :haml
    load_path 'vendor/authlogic/lib'
    require 'authlogic'
  end
end
</pre>

Then in your library file (<code>lib/whatever.rb</code>):

<pre>
require File.expand_path("#{File.dirname(__FILE_)}/../require")
Require.lib!
</pre>

* Activates sinatra and haml gems
* Requires sinatra, haml, and sass
* Adds vendor/authlogic/lib to the load paths
* Requires authlogic

Gemspec
-------

You can also use <code>Require</code> to generate a <code>Gem::Specification</code> instance.

<pre>
require 'rubygems'
gem 'require'
require 'require'

Require do

  gem(:sinatra, '=0.9.4') { require 'sinatra/base' }

  gemspec do
    author 'Your Name'
    dependencies do
      gem :sinatra
    end
    email 'your@email.com'
    name 'my_project'
    homepage "http://github.com/your_name/#{name}"
    summary ""
    version '0.1.0'
  end
end
</pre>

Then use it in your <code>rakefile</code>:

<pre>
require File.dirname(__FILE_) + "/require"

desc "Package gem"
Rake::GemPackageTask.new(Require.gemspec) do |pkg|
  pkg.gem_spec = Require.gemspec
end
</pre>