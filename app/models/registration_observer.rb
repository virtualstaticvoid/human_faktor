class RegistrationObserver < ActiveRecord::Observer

  def after_create(registration)
    Resque.enqueue(AccountProvisioner, registration.id)
  end

end      


