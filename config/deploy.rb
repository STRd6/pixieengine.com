require 'delayed/recipes'
require "bundler/capistrano"

default_run_options[:pty] = true

set :application, "pixie.strd6.com"

set :use_sudo, false

set :scm, "git"
set :repository, "git://github.com/STRd6/#{application}.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :default_env, 'production'
set :rails_env, ENV['rails_env'] || ENV['RAILS_ENV'] || default_env

set :default_environment, {
  'PATH' => "/home/daniel/.rvm/bin:/home/daniel/.rvm/gems/ree-1.8.7-2010.02/bin:/home/daniel/.rvm/gems/ree-1.8.7-2010.02@global/bin:/home/daniel/.rvm/rubies/ree-1.8.7-2010.02/bin:$PATH",
  'RUBY_VERSION' => 'ruby 1.8.7',
  'GEM_HOME' => '/home/daniel/.rvm/gems/ree-1.8.7-2010.02',
  'GEM_PATH' => '/home/daniel/.rvm/gems/ree-1.8.7-2010.02:/home/daniel/.rvm/gems/ree-1.8.7-2010.02@global'
}

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

ssh_options[:port] = 2112

role :app, "67.207.139.110"
role :web, "67.207.139.110"
role :db,  "67.207.139.110", :primary => true


after :deploy do
  run "chmod -R g+w #{release_path}/tmp"
end
after :deploy, "deploy:cleanup"

# Whenever task
after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end

after :setup do
  run "mkdir #{shared_path}/production"
  run "mkdir #{shared_path}/production/images"
  run "mkdir #{shared_path}/production/replays"
  run "mkdir #{shared_path}/db"
  run "mkdir #{shared_path}/backups"
  run "mkdir #{shared_path}/local"
  run "touch #{shared_path}/log/nginx.log"
  run "touch #{shared_path}/log/nginx.error.log"
end

after "deploy:update_code" do
  run "ln -nfs #{shared_path}/production #{release_path}/public/production"
  run "ln -nfs #{shared_path}/local/authlogic.yml #{release_path}/config/authlogic.yml"
  run "ln -nfs #{shared_path}/local/local.rake #{release_path}/lib/tasks/local.rake"
  run "ln -nfs #{shared_path}/local/s3.yml #{release_path}/config/s3.yml"
  run "ln -nfs #{shared_path}/local/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/local/settings.yml #{release_path}/config/settings.yml"
end

# Passenger start Tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end
