class Admin::EventTypesController < Admin::AdminController
  
  def index
    @event_types = EventType.all
  end
end
