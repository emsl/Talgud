class EventParticipantSweeper < ActionController::Caching::Sweeper
  
  observe EventParticipant
  
  def after_create(event_participant)
    expire_action(:controller => '/events', :action => 'map', :format => 'json')
  end
  
  def after_update(event_participant)
    expire_action(:controller => '/events', :action => 'map', :format => 'json')
  end
  
  def after_destroy(event_participant)
    expire_action(:controller => '/events', :action => 'map', :format => 'json')
  end
end