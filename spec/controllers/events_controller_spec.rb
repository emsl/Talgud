require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController, 'index' do
  it 'should show a list of events'
  
  it 'should be accessible by all users' do
    event = Factory(:event, :status => Event::STATUS[:new])
    get :show, {:id => event.url}
    response.should redirect_to(root_path)
    #assigns[:event].should eql(event)
  end
end

describe EventsController, 'new' do
  it 'should not be displayed when user is not logged in' do
    get :new
    response.should redirect_to(root_path)
  end
  
  it 'should be displayed when any user is logged in' do
    pending 'Tarmo teeb seda veel' do
      activate_authlogic
      UserSession.create Factory.build(:user)
      
      get :new
      response.should be_success
    end
  end
end

describe EventsController, 'create' do
  it 'should create event and assign current user as manager when event is valid'
  
  it 'should send e-mail notification to region manager'
  
  it 'should redisplay event create form when event data is invalid'
end

describe EventsController, 'show' do
  it 'should load event by event URL' do
    event = Factory(:event, :status => Event::STATUS[:new] )
    get :show, {:id => event.url}
    response.should be_success
    assigns[:event].should eql(event)
  end
  
  it 'should not show unpublished event to public users' do
    event = Factory(:event, :status => Event::STATUS[:new])
    get :show, {:id => event.url}
    response.should redirect_to(root_path)
  end
  
  it 'should show published event to event owner'
  
  it 'should show unpublished event to event owner'
end
