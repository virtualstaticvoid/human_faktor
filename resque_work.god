rails_env   = ENV['RAILS_ENV']  || "production"
rails_root  = ENV['RAILS_ROOT'] || File.dirname(__FILE__)
num_workers = ENV['RESQUE_WORKERS'] || 1
rake_path   = ENV['RAKE_PATH'] || '/usr/local/rvm/gems/ruby-1.9.2-p180/bin/rake'
queue_name  = ENV['QUEUE'] || '*'

num_workers.times do |num|
  God.watch do |w|
    w.dir      = "#{rails_root}"
    w.name     = "resque-#{num}"
    w.group    = 'resque'
    w.interval = 30.seconds
    w.start    = "#{rake_path} -f #{rails_root}/Rakefile resque:work RAILS_ENV=#{rails_env} QUEUE='#{queue_name}'"

    w.uid = 'www-data'
    w.gid = 'www-data'

    # retart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
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

