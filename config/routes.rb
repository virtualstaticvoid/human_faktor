HumanFaktor::Application.routes.draw do

  get "home/about"
  get "home/contact"
  get "home/features"
  get "home/subscriptions"
  get "home/terms"
  get "home/partner"
  get "home/sign_in"

  get "registrations/new", :to => 'registrations#new', :as => :new_account_registration  
  post "registrations", :to => 'registrations#create', :as => :create_account_registration  
  get "registrations/:id", :to => 'registrations#show', :as => :account_registration
  get "registrations/:id/query/:started(.:format)", :to => 'registrations#query', :as => :query_account_registration

  devise_for :employees
  # TODO: configuration for devise

  root :to => "home#index"

end
