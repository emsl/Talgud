class Admin::EventTypesController < Admin::AdminController
  filter_resource_access
  
  def index
    @event_types = EventType.all
  end
end
