class HomeController < ApplicationController
  filter_resource_access
  
  def index
    @events = Event.with_permissions_to(:read).all(:select => 'name, url, latitude, longitude')
    @latest = Event.with_permissions_to(:read).latest(5).all(:select => 'name, url')
  end
end
