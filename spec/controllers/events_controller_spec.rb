require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController, 'index' do
  it 'should show a list of events'
end

describe EventsController, 'new' do
  it 'should not be displayed when user is not logged in' do
    pending('This needs role management to pass') do
      get :new
      response.should redirect_to(events_path)
    end
  end
end

describe EventsController, 'create' do
  it 'should create event and assign current user as manager when event is valid'
  
  it 'should send e-mail notification to region manager'
  
  it 'should redisplay event create form when event data is invalid'
end