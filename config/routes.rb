ActionController::Routing::Routes.draw do |map|
  
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  
  map.namespace :admin do |admin|
    admin.resources :users
  end
  
  map.resources :user_sessions
end
