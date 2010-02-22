require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController, 'index' do
  it 'should show a list of events'
end

describe EventsController, 'new' do
  it 'should not be displayed when user is not logged in'
end

describe EventsController, 'create' do
  it 'should create event and assign current user as manager when event is valid'
  
  it 'should redisplay event create form when event data is invalid'
end