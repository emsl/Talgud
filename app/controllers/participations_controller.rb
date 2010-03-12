class ParticipationsController < ApplicationController
  
  before_filter :load_event
  
  def index
    @event_participants = @event.event_participants
  end
  
  def new
    @event_participant = EventParticipant.new(:event => @event)
  end
  
  def create
    @event_participant = EventParticipant.new(params[:event_participant])
    @event_participant.event = @event
    
    if @event_participant.valid?
      @event_participant.save
      
      # Deliver load of emails to all parties that might be interested in such participation
      Mailers::EventMailer.deliver_participant_notification(@event_participant, event_url(@event), event_participation_url(@event, UrlStore.encode(@event_participant.id)))
      @event.managers.each do |manager|
        Mailers::EventMailer.deliver_manager_participation_notification(manager, @event_participant, event_participations_url(@event))
      end
      @event_participant.recommend_emails.each do |email|
        Mailers::EventMailer.deliver_tell_friend_notification(email, @event_participant, event_url(@event))
      end
      
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
