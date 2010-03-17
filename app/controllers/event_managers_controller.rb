class EventManagersController < ApplicationController
  
  before_filter :load_event
  
  def new
    @manager = User.new
  end
  
  def create
    @manager = User.find_by_email(params[:user][:email])
    
    if @manager
      if Role.has_role?(Role::ROLE[:event_manager], @manager, @event)
        flash.now[:error] = t('event_managers.create.role_exists')
        render :action => :new
      else
        Role.grant_role(Role::ROLE[:event_manager], @manager, @event)
        Mailers::EventMailer.deliver_invite_event_manager_notification(current_user, @manager, @event, login_url)
      
        flash[:notice] = t('event_managers.create.notice')
        redirect_to event_path(@event)
      end
    else
      @manager = User.new(params[:user])
      password = @manager.reset_password
      if @manager.valid?
        @manager.save
        @manager.activate!
        
        Role.grant_role(Role::ROLE[:event_manager], @manager, @event)
        Mailers::EventMailer.deliver_invite_event_manager_notification(current_user, @manager, @event, login_url, password)
        
        flash[:notice] = t('event_managers.create.notice')
        redirect_to event_path(@event)
      else
        flash.now[:error] = t('event_managers.create.error')
        render :action => :new
      end
    end
  end
  
  private
  
  def load_event
    @event = Event.can_manage(@current_user).find_by_url(params[:event_id]) if @current_user
    redirect_to(root_path) unless @event
  end
end
