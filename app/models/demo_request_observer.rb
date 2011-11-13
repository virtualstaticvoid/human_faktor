class DemoRequestObserver < ActiveRecord::Observer

  def after_create(demo_request)
    WorkQueue.enqueue(DemoRequestSystemMailer, demo_request.id)
    WorkQueue.enqueue(DemoRequestMailer, demo_request.id)
  end

end      


