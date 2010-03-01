class HomeController < ApplicationController
  filter_resource_access
  
  def index
    @latest = Event.published.latest(5).all(:include => [:location_address_county, :location_address_municipality, :location_address_settlement])
  end
end
