class Admin::EventsController < Admin::AdminController
  filter_resource_access
  
  def index
    @events = Event.all
  end
end
