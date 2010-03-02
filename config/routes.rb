ActionController::Routing::Routes.draw do |map|
  
  map.activate '/activations/:activation_code', :controller => 'signups', :action => 'activate'
  map.admin 'admin', :controller => 'admin/events'
  map.admin_login '/admin/login', :controller => 'admin/user_sessions', :action => 'new'
  map.admin_logout '/admin/logout', :controller => 'admin/user_sessions', :action => 'destroy'
  map.home 'home', :controller => 'home'
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
    admin.resources :events, :collection => {:map => :get}
    admin.resources :event_types
    admin.resources :user_sessions
    admin.resources :users
    admin.resources :languages
    admin.resources :roles
  end
  
  map.resources :addresses, :collection => {:municipalities => :get, :settlements => :get}
  map.resources :events, :collection => {:my => :get, :map => :get, :latest => :get} 
  map.resources :password_reminders
  map.resources :signups
  map.resources :user_sessions
  map.resources :users
end
