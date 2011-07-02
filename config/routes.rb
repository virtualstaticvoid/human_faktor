HumanFaktor::Application.routes.draw do

  ###
  # routes for base
  #

  get "about", :to => 'home#about', :as => :home_about
  get "contact", :to => 'home#contact', :as => :home_contact
  get "features", :to => 'home#features', :as => :home_features
  get "subscriptions", :to => 'home#subscriptions', :as => :home_subscriptions
  get "terms", :to => 'home#terms', :as => :home_terms
  get "partner", :to => 'home#partner', :as => :home_partner
  get "sign_in", :to => 'home#sign_in', :as => :home_sign_in

  get "registrations/new", :to => 'registrations#new', :as => :new_account_registration
  post "registrations", :to => 'registrations#create', :as => :create_account_registration
  get "registrations/:id", :to => 'registrations#show', :as => :account_registration
  get "registrations/:id/query/:started(.:format)", :to => 'registrations#query', :as => :query_account_registration

  ###
  # routes for tenant
  #

  scope "*tenant" do

    get "setup", :to => "tenant/account_setup#index", :as => :account_setup

    devise_for :employees, :path => "" do
      # TODO: additional configuration for devise
    end

    # dashboard
    get "profile", :to => "tenant/dashboard#profile", :as => :profile
    get "balance", :to => "tenant/dashboard#balance", :as => :balance
    get "calendar", :to => "tenant/dashboard#calendar", :as => :calendar
    get "staff_calendar", :to => "tenant/dashboard#staff_calendar", :as => :staff_calendar

    # leave requests
    get "leave", :to => "tenant/leave_requests#employee_index", :as => :leave_requests
    get "staff_leave", :to => "tenant/leave_requests#staff_index", :as => :staff_leave_requests
    get "leave/new", :to => "tenant/leave_requests#new", :as => :new_leave_request
    post "leave", :to => "tenant/leave_requests#create", :as => :create_leave_request
    get "leave/:id", :to => "tenant/leave_requests#edit", :as => :edit_leave_request
    put "leave/:id/confirm", :to => "tenant/leave_requests#confirm", :as => :confirm_leave_request
    put "leave/:id/approve", :to => "tenant/leave_requests#approve", :as => :approve_leave_request
    put "leave/:id/decline", :to => "tenant/leave_requests#decline", :as => :decline_leave_request
    put "leave/:id/cancel", :to => "tenant/leave_requests#cancel", :as => :cancel_leave_request

    # data feeds
    get "calendar_entries_feed(.:format)", :to => "tenant/data_feeds#calendar_entries", :as => :calendar_entries_feed
    get "leave_requests_feed(.:format)", :to => "tenant/data_feeds#leave_requests", :as => :leave_requests_feed

    scope "account" do

      get "edit", :to => "tenant/account#edit", :as => :edit_account
      put "edit", :to => "tenant/account#update", :as => :update_account

      get "policies", :to => "tenant/leave_types#edit", :as => :edit_leave_types
      put "policies", :to => "tenant/leave_types#update", :as => :update_leave_types

      resources :locations
      resources :departments
      resources :employees

      get "/", :to => "tenant/account#index", :as => :account

    end

    get "/", :to => "tenant/dashboard#index", :as => :dashboard

  end

  root :to => "home#index"

end

