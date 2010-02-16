ActionController::Routing::Routes.draw do |map|
  
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  
  map.namespace :admin do |admin|
    admin.resources :counties do |county|
      county.resources :municipalities do |municipality|
        municipality.resources :settlements
      end
    end
    admin.resources :users
  end
  
  map.resources :user_sessions
end
