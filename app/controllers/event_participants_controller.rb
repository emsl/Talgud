class EventParticipantsController < ApplicationController

  before_filter :load_event  
  filter_resource_access :attribute_check => true  
  filter_access_to [:new, :show, :create, :edit, :update, :new_mail, :create_mail], :require => :manage

  helper :participations
  
  cache_sweeper :event_participant_sweeper, :only => [:update, :destroy]

  def index
    respond_to do |format|
      format.html do
        @event_participants = @event.event_participants.all(:order => :id, :include => :children)
      end
      format.csv do
        @event_participants = @event.event_participants.search(:ordered_by_name => true).all
        @filename = "event-participans-#{@event.code}-#{Time.now.strftime("%Y%m%d")}.csv"
      end
      format.xls do
        @event_participants = @event.event_participants.search(:ordered_by_name => true).all
        @filename = "event-participans-#{@event.code}-#{Time.now.strftime("%Y%m%d")}.xls"
      end
    end
  end

  def new_mail
    @mail ||= Mail.new(:event => @event)
    @mail.to = @mail.to_emails * ', '
    @mail.from = @mail.from_emails * ', '
    @mail.reply_to = @mail.reply_to_emails * ', '
  end

  def create_mail
    @mail = Mail.new(params[:mail])
    @mail.event = @event
    @mail.to = @mail.to_emails * ', '
    @mail.from = @mail.from_emails * ', '
    @mail.reply_to = @mail.reply_to_emails * ', '
    
    if @mail.valid?
      Mailers::EventMailer.deliver_participants_manager_notification(@mail, event_url(@event))
      
      flash[:notice] = t('event_participants.create_mail.notice')
      redirect_to event_event_participants_path(@event)
    else
      flash.now[:error] = t('event_participants.create_mail.error')
      render :new_mail
    end    
  end

  def edit
  end

  def update
    previous_children = @event_participant.children.collect{ |c| c.id }

    @event_participant.attributes = params[:event_participant]
    if @event_participant.valid? & @event_participant.children_valid?
      @event_participant.save
      @event_participant.children.select{ |c| not c.email.blank? }.each do |c|
        unless previous_children.include?(c.id)
          Mailers::EventMailer.deliver_invite_participant_notification(c, event_url(@event), event_participation_redirect_url(UrlStore.encode(c.id)))
        end
      end

      flash[:notice] = t('participations.update.notice')
      if @current_user
        redirect_to event_event_participants_path(@event)
      else        
        redirect_to event_path(@event)
      end
    else
      flash.now[:error] = t('participations.update.error')
      render :edit
    end
  end

  def destroy
    @event_participant.destroy
    flash[:notice] = t('participations.destroy.notice')
    redirect_to event_event_participants_path(@event)
  end

  private

  def load_event
    @event = Event.can_manage(@current_user).find_by_url(params[:event_id])
    redirect_to login_path unless @event
  end

  def load_event_participant
    @event_participant = @event.event_participants.find(params[:id])
  end
end