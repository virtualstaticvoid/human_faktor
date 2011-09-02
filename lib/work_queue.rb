require 'delayed_job'

module WorkQueue

  def self.enqueue(job_type, *args)
    # implemented via delayed_job (could also use Resque)
    Delayed::Job.enqueue job_type.new(*args)
  end

end
