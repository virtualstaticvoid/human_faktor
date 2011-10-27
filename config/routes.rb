HumanFaktor::Application.routes.draw do

  ###
  # routes for base
  #
  
  # NNB: be sure to update the subdomain validator options for account to 
  #      include these paths as restricted names

  get "contact", :to => 'home#contact', :as => :home_contact
  get "features", :to => 'home#features', :as => :home_features
  get "subscriptions", :to => 'home#subscriptions', :as => :home_subscriptions
  get "terms", :to => 'home#terms', :as => :home_terms
  get "privacy", :to => 'home#privacy', :as => :home_privacy
  get "partner", :to => 'home#partner', :as => :home_partner
  get "sign_in", :to => 'home#sign_in', :as => :home_sign_in

  get "demo_request", :to => 'demo_requests#new', :as => :new_demo_request
  post "demo_request", :to => 'demo_requests#create', :as => :create_demo_request

  get "registrations/new", :to => 'registrations#new', :as => :new_account_registration
  post "registrations", :to => 'registrations#create', :as => :create_account_registration
  get "registrations/:id", :to => 'registrations#show', :as => :account_registration
  get "registrations/:id/query/:started(.:format)", :to => 'registrations#query', :as => :query_account_registration

  ###
  # routes for tenant
  #

  # NOTE: this part of the route is "globbed" and there are some issues 
  #       in Rails when there are nested routes, so a `:tenant => current_account.subdomain` option 
  #       is required for url helpers when constructing paths
  scope "*tenant" do

    get "setup", :to => "tenant/account_setup#edit", :as => :account_setup
    put "setup", :to => "tenant/account_setup#update", :as => :update_account_setup

    devise_for :employees, :path => "" do
      # TODO: additional configuration for devise
    end

    get "welcome", :to => "tenant/dashboard#welcome", :as => :welcome

    # dashboard
    get "balance", :to => "tenant/dashboard#balance", :as => :balance

    get "staff_balance", :to => "tenant/dashboard#staff_balance", :as => :staff_balance
    post "staff_balance", :to => "tenant/dashboard#staff_balance"

    get "calendar", :to => "tenant/dashboard#calendar", :as => :calendar

    get "staff_calendar", :to => "tenant/dashboard#staff_calendar", :as => :staff_calendar
    post "staff_calendar", :to => "tenant/dashboard#staff_calendar"

    get "heatmap", :to => "tenant/dashboard#heatmap", :as => :heatmap
    post "heatmap", :to => "tenant/dashboard#heatmap"

    get "help", :to => "tenant/dashboard#help", :as => :help
    
    # profile
    get "activate", :to => "tenant/profile#activate", :as => :activate
    put "activate", :to => "tenant/profile#setactive", :as => :activate
    
    get "profile", :to => "tenant/profile#edit", :as => :profile
    put "profile", :to => "tenant/profile#update", :as => :update_profile

    # employee leave requests
    get "leave", :to => "tenant/employee_leave_requests#index", :as => :employee_leave_requests
    post "leave", :to => "tenant/employee_leave_requests#index"
    get "leave/new", :to => "tenant/employee_leave_requests#new", :as => :new_employee_leave_request
    post "leave/new", :to => "tenant/employee_leave_requests#create", :as => :create_employee_leave_request

    # staff leave requests
    get "staff_leave", :to => "tenant/staff_leave_requests#index", :as => :staff_leave_requests
    post "staff_leave", :to => "tenant/staff_leave_requests#index"
    get "staff_leave/new", :to => "tenant/staff_leave_requests#new", :as => :new_staff_leave_request
    post "staff_leave/new", :to => "tenant/staff_leave_requests#create", :as => :create_staff_leave_request

    # both employee and staff leave requests
    resources :leave_requests, :path => '/leave', :module => 'tenant', :except => [:index, :new, :create, :edit, :update, :destroy] do
      member do
        get 'amend'
        put 'confirm'
        put 'approve'
        put 'decline'
        put 'cancel'
        put 'reinstate'
        put 'update_constraints'
        put 'update_document'
      end
    end

    get "leave_balance", :to => "tenant/leave_requests#balance", :as => :leave_balance

    # data feeds
    get "calendar_entries_feed(.:format)", :to => "tenant/data_feeds#calendar_entries", :as => :calendar_entries_feed
    get "leave_requests_feed(.:format)", :to => "tenant/data_feeds#leave_requests", :as => :leave_requests_feed
    get "employee_staff(.:format)", :to => "tenant/data_feeds#employee_staff", :as => :employee_staff_feed

    scope "account" do

      get "edit", :to => "tenant/account#edit", :as => :edit_account
      put "edit", :to => "tenant/account#update", :as => :update_account

      get "policies", :to => "tenant/leave_types#edit", :as => :edit_leave_types
      put "policies", :to => "tenant/leave_types#update", :as => :update_leave_types

      resources :locations, :module => 'tenant'
      resources :departments, :module => 'tenant'
      
      get 'employees/filtered', :to => 'tenant/employees#filtered'
      post 'employees/filtered', :to => 'tenant/employees#filtered', :as => :employees_filtered

      resources :employees, :module => 'tenant' do
        member do
          put 'deactivate'
          put 'reactivate'
        end
      end

      get "employee_balance(.:format)", :to => "tenant/employees#balance", :as => :employee_balance

      resources :bulk_uploads, :module => 'tenant', :except => [:index] do
        member do
          get 'download'
        end
        get 'template', :to => 'bulk_uploads#template', :as => :template, :on => :collection
        get 'records', :to => 'bulk_upload_stages#index', :as => :records
        put 'records', :to => 'bulk_upload_stages#index'
      end
      
      get "/", :to => "tenant/account#index", :as => :account

    end

    get "/", :to => "tenant/dashboard#index", :as => :dashboard

  end

  root :to => "home#index"

end

