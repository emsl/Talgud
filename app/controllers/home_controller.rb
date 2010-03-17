class HomeController < ApplicationController
  filter_resource_access
  
  def index
    @latest = Event.published.latest(5).all(:include => [:location_address_county, :location_address_municipality, :location_address_settlement])
    
    @max_participants = Event.published.sum(:max_participants)
    @current_participants = Event.published.sum('case when current_participants > max_participants then max_participants else current_participants end').to_i
    @needed_participants = [(@max_participants - @current_participants), 0].max
  end
end
