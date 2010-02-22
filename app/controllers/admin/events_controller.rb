class Admin::EventsController < Admin::AdminController
  def index
    @events = Event.all
  end
end
