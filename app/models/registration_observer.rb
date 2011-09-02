class RegistrationObserver < ActiveRecord::Observer

  def after_create(registration)
    WorkQueue.enqueue(AccountProvisioner, registration.id)
  end

end      


