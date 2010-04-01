class EventSweeper < ActionController::Caching::Sweeper
  
  observe Event
  
  def after_create(event)
    expire_action(:controller => '/events', :action => 'map', :format => 'json')
  end
  
  def after_update(event)
    expire_action(:controller => '/events', :action => 'map', :format => 'json')
  end
  
  def after_destroy(event)
    expire_action(:controller => '/events', :action => 'map', :format => 'json')
  end
end