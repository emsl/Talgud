class ParticipationsController < ApplicationController
  
  before_filter :load_event
  
  def new
    @event_participant = EventParticipant.new(:event => @event)
  end
  
  def create
    @event_participant = EventParticipant.new(params[:event_participant])
    @event_participant.event = @event
    
    if @event_participant.valid?
      @event.save
      redirect_to event_path(@event)
    else
      flash[:error] = "Error error"
      render :new
    end
  end
  
  private
  
  def load_event
    @event = Event.find_by_url(params[:event_id])
  end
end
