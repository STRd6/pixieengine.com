require "bundler/capistrano"

default_run_options[:pty] = true

set :application, "pixie.strd6.com"

set :use_sudo, false

set :scm, "git"
set :repository, "git://github.com/PixieEngine/pixieengine.com.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :user, :rails

set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

# We only have a production environment right now
set :rails_env, 'production'

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
after :deploy, "deploy:migrate"
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
  run "mkdir -p #{shared_path}/sockets"
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
load 'deploy/assets' # This is loaded down here to have the above update code callback run first

# Unicorn start Tasks
namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec unicorn -c #{unicorn_config} -E #{rails_env} -D"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end

  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end

  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
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
end
