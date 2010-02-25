class HomeController < ApplicationController
  filter_resource_access
  
  def index
    @events = Event.published(:select => 'name, url, latitude, longitude')
    @latest = Event.published.latest(5).all(:select => 'name, url')
  end
end
