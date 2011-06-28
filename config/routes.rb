HumanFaktor::Application.routes.draw do

  get "home/about"
  get "home/contact"
  get "home/features"
  get "home/subscriptions"
  get "home/terms"
  get "home/partner"
  get "home/sign_in"

  get "registrations/new", :to => 'registrations#new', :as => :new_registration  
  post "registrations", :to => 'registrations#create'
  get "registrations/:id", :to => 'registrations#show', :as => :registration
  get "registrations/:id/query/:started(.:format)", :to => 'registrations#query', :as => :query_registration

  root :to => "home#index"

end
