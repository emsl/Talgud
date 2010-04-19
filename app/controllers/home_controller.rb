class HomeController < ApplicationController
  filter_resource_access
  
  def index
    @latest = Event.published.latest(5).all(:include => [:location_address_county, :location_address_municipality, :location_address_settlement])
    
    @event_count = Event.published.count
    @max_participants = Event.published.sum(:max_participants)
    @current_participants = Event.published.sum(:current_participants).to_i
    @needed_participants = [(@max_participants - @current_participants), 0].max
  end
end
