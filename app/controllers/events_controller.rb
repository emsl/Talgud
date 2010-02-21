class EventsController < ApplicationController
  
  def new
    @event = Event.new
  end
  
  def create
    @event = Event.new(params[:event])
    if @event.valid?
      @event.save
      flash[:notice] = t('events.create.notice')
      redirect_to event_path(@event)
    else
      render :new
      flash[:error] = t('events.create.error')
    end
  end
  
  def show
    @event = Event.find(params[:id])
  end
end
