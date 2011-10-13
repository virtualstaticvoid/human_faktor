# for now, keep a history of jobs
Delayed::Worker.destroy_failed_jobs = false

# configure logging
Delayed::Worker.logger = ActiveSupport::BufferedLogger.new("log/#{Rails.env}_delayed_job.log", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1

#
# check if run from $./script/delayed_job 
#

if caller.last =~ /^script\/delayed_job:.*$/

  ActiveRecord::Base.logger = Delayed::Worker.logger

  #  
  # Ensure all workers get required, so delayed_job doesn't silently fail when deserializing jobs
  # See https://github.com/collectiveidea/delayed_job/wiki/Common-problems#wiki-jobs_are_silently_removed_from_the_database for details
  #
  
  worker_path = File.expand_path('../../../app/workers', __FILE__)
  Dir[File.join(worker_path, '**/**.rb')].each do |file|
    puts ">>>> #{file}"
    require file
  end

end
