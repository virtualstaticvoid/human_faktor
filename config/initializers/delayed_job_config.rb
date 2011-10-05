# for now, keep a history of jobs
Delayed::Worker.destroy_failed_jobs = false

# change the default logger
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', "#{Rails.env}_delayed_job.log"))

