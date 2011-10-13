# for now, keep a history of jobs
Delayed::Worker.destroy_failed_jobs = false

# configure logging
Delayed::Worker.logger = ActiveSupport::BufferedLogger.new("log/#{Rails.env}_delayed_job.log", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1

if caller.last =~ /.*\/script\/delayed_job:\d+$/
  ActiveRecord::Base.logger = Delayed::Worker.logger
end
