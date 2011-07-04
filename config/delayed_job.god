RAILS_ROOT = "/u/apps/pixie.strd6.com/current"

1.times do |num|
  God.watch do |w|
    w.name = "dj-#{num}"
    w.group = 'dj'
    w.interval = 30.seconds
    w.start = "bundle exec rake -f #{RAILS_ROOT}/Rakefile RAILS_ENV=production jobs:work"

    w.uid = 'rails'
    w.gid = 'rails'

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 100.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end
