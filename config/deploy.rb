# config valid only for Capistrano 3.1
lock '3.1.0'

set :ssh_options, {
  user: :rails,
  port: 2112
}

set :application, "pixieengine.com"
set :scm, "git"
set :repo_url, 'git://github.com/PixieEngine/pixieengine.com.git'
set :branch, "master"
set :deploy_via, :remote_cache
set :copy_exclude, [ '.git' ]
# set :user, :rails

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/pixieengine.com'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_command, "bundle exec whenever"

namespace :deploy do
  task :start do
    on roles(:app) do
      sudo "start pixieengine.com"
    end
  end

  task :stop do
    on roles(:app) do
      sudo "stop pixieengine.com"
    end
  end

  task :restart do
    on roles(:app) do
      sudo "restart pixieengine.com"
    end
  end

  after :finished, :restart

  before 'assets:precompile', :migrate

  task :create_symlinks do
    on roles(:web) do
      execute "ln -nfs #{shared_path}/production #{release_path}/public/production"
      execute "ln -nfs #{shared_path}/local/s3.yml #{release_path}/config/s3.yml"
      execute "ln -nfs #{shared_path}/local/oauth.yml #{release_path}/config/oauth.yml"
      execute "ln -nfs #{shared_path}/local/database.yml #{release_path}/config/database.yml"
      execute "ln -nfs #{shared_path}/local/settings.yml #{release_path}/config/settings.yml"
    end
  end

  before :migrate, :create_symlinks
end

task :setup_shared_paths do
  on roles(:web) do
    execute "mkdir -p #{shared_path}/local"
    execute "mkdir -p #{shared_path}/log"
    execute "mkdir -p #{shared_path}/pids"
    execute "mkdir -p #{shared_path}/production"
    execute "mkdir -p #{shared_path}/production/images"
    execute "mkdir -p #{shared_path}/production/replays"
    execute "mkdir -p #{shared_path}/sockets"
    execute "touch #{shared_path}/log/nginx.log"
    execute "touch #{shared_path}/log/nginx.error.log"
  end
end

before :deploy, :setup_shared_paths
