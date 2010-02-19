ActionController::Routing::Routes.draw do |map|
  
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.admin 'admin', :controller => 'admin/events'
  map.signup 'signup', :controller => 'signups', :action => 'new'
  map.activate '/activations/:activation_code', :controller => 'signups', :action => 'activate'
  
  map.namespace :admin do |admin|
    admin.resources :counties do |county|
      county.resources :municipalities do |municipality|
        municipality.resources :settlements
      end
    end
    admin.resources :events
    admin.resources :users
  end
  
  map.resources :events
  map.resources :signups
  map.resources :user_sessions
  
  map.home 'home', :controller => 'home'
  map.root :home
end
