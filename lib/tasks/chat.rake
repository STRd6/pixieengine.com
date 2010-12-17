namespace :chat do
  desc "start redis"
  task :redis do
    `redis-server &`
  end

  desc "start juggernaut"
  task :juggernaut do
    `cd vendor/juggernaut/ && node server.js &`
  end

  task :start => [:redis] #, :juggernaut]
end