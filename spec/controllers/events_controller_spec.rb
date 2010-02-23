require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController, 'index' do
  it 'should show a list of events'
end

describe EventsController, 'new' do
  it 'should not be displayed when user is not logged in' do
    get :new
    response.should redirect_to(events_path)
  end
  
  it 'should be displayed when any user is logged in' do
    activate_authlogic
    UserSession.create Factory.build(:user)
    
    get :new
    response.should be_success
  end
end

describe EventsController, 'create' do
  it 'should create event and assign current user as manager when event is valid'
  
  it 'should send e-mail notification to region manager'
  
  it 'should redisplay event create form when event data is invalid'
end
