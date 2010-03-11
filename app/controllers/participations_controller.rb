class ParticipationsController < ApplicationController
  
  before_filter :load_event
  
  def new
    @event_participant = EventParticipant.new(:event => @event)
  end
  
  def create
    @event_participant = EventParticipant.new(params[:event_participant])
    @event_participant.event = @event
    
    if @event_participant.valid?
      @event_participant.save
      
      # TODO: send email to registrant
      # TODO: send email to event managers
      # TODO: send email to "friends"
      
      flash[:notice] = t('participations.create.notice')
      redirect_to event_path(@event)
    else
      flash[:error] = t('participations.create.error')
      render :new
    end
  end
  
  private
  
  def load_event
    @event = Event.find_by_url(params[:event_id])
  end
end
