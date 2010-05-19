ActionController::Routing::Routes.draw do |map|
  
  map.activate '/activations/:activation_code', :controller => 'signups', :action => 'activate'
  map.admin 'admin', :controller => 'admin/events'
  map.admin_login '/admin/login', :controller => 'admin/user_sessions', :action => 'new'
  map.admin_logout '/admin/logout', :controller => 'admin/user_sessions', :action => 'destroy'
  map.home 'home', :controller => 'home', :action => 'index'
  map.language '/:language', :controller => 'home', :action => 'index', :language => /[a-z]{2}/
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.root :home
  map.signup 'signup', :controller => 'signups', :action => 'new'
  
  map.namespace :admin do |admin|
    admin.resources :counties do |county|
      county.resources :municipalities do |municipality|
        municipality.resources :settlements
      end
    end
    admin.resources :events, :collection => {:map => :get} do |event|
      event.resources :participations, :controller => :event_participants
    end
    admin.resources :participants, :controller => :participants
    admin.resources :event_types
    admin.resources :user_sessions
    admin.resources :users
    admin.resources :languages
    admin.resources :roles
    admin.resources :accounts
  end
  
  map.resources :addresses, :collection => {:municipalities => :get, :settlements => :get}
  map.resources :events, :collection => {:my => :get, :map => :get, :latest => :get, :past => :get, :stats => :get} do |event|
    event.resources :participations, :member => {:confirmation => :get}
    event.resources :managers, :controller => :event_managers
    event.resources :event_participants, :collection => {:new_mail => :get, :create_mail => :post}
  end
  map.event_participation_redirect 'participation/:id', :controller => :participations, :action => :redirect
  map.resources :password_reminders
  map.resources :signups
  map.resources :user_sessions
  map.resources :users
end
