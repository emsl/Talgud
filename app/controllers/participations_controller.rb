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
      
      Mailers::EventMailer.deliver_participant_notification(@event, @event_participant)
      @event.managers.each do |manager|
        Mailers::EventMailer.deliver_manager_paricipation_notification(@event, manager, @event_participant)
      end
      @event_participant.recommend_emails.each do |email|
        Mailers::EventMailer.deliver_tell_friend_notification(email, @event, @event_participant)
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
