require 'delayed_job'

module WorkQueue

  def self.enqueue(job_type, *args)
    puts "Queuing job: #{job_type} [#{args.to_s}]"
    # implemented via delayed_job (could also use Resque)
    Delayed::Job.enqueue job_type.new(*args)
  end

end
