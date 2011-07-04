require "bundler/capistrano"

default_run_options[:pty] = true

set :application, "pixie.strd6.com"

set :use_sudo, false

set :scm, "git"
set :repository, "git://github.com/STRd6/#{application}.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :user, :rails

set :default_env, 'production'
set :rails_env, ENV['rails_env'] || ENV['RAILS_ENV'] || default_env

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

ssh_options[:port] = 2112

app_ip = "173.255.220.219"

role :app, app_ip
role :web, app_ip
role :db,  app_ip, :primary => true

after :deploy do
  run "chmod -R g+w #{release_path}/tmp"
  run "chmod -R g+w #{release_path}/.bundle"
end
after :deploy, "deploy:cleanup"

# Whenever task
after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
  end
end

after "deploy:setup" do
  run "mkdir -p #{shared_path}/production"
  run "mkdir -p #{shared_path}/production/images"
  run "mkdir -p #{shared_path}/production/replays"
  run "mkdir -p #{shared_path}/local"
  run "touch #{shared_path}/log/nginx.log"
  run "touch #{shared_path}/log/nginx.error.log"
end

after "deploy:update_code" do
  run "ln -nfs #{shared_path}/production #{release_path}/public/production"
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

namespace :tail do
  desc "tail Rails log files"
  task :logs, :roles => :app do
    run "tail -fn50 #{shared_path}/log/production.log" do |channel, stream, data|
      puts data
      break if stream == :err
    end
  end

  desc "tail delayed_job log files"
  task :jobs, :roles => :app do
    run "tail -fn50 #{shared_path}/log/delayed_job.log" do |channel, stream, data|
      puts data
      break if stream == :err
    end
  end
end
