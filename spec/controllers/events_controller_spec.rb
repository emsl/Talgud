require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController, 'index' do
  it 'should show a list of events' do
    events = Array.new(10) { |i| Factory.create(:event) }
    
    get :index
    assigns[:events].each { |e| events.should include(e) }
  end
  
  it 'should be accessible by all users' do
    get :index
    response.should be_success
  end
end

describe EventsController, 'new' do
  it 'should not be displayed when user is not logged in' do
    get :new
    response.should redirect_to(root_path)
  end
  
  it 'should be displayed when user is logged in' do
    activate_authlogic
    UserSession.create Factory.create(:user)
      
    get :new
    response.should be_success
  end
end

describe EventsController, 'create' do
  before(:each) do
    @user = Factory.create(:user)
    @event = Factory.build(:event)
  end
  
  context 'with authenticated users' do
    before(:each) do
      activate_authlogic
      UserSession.create @user
    end
    
    it 'should create event and assign current user as manager when event is valid' do
      post :create, {:event => @event.attributes}
      response.should redirect_to(event_path(assigns[:event]))
      assigns[:event].manager.should eql(@user)
    end
    
    it 'should send e-mail notification to region manager' do
      county = Factory(:county)
      regional_manager = Factory(:user)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, county)
      
      @event.location_address_county = county
      Mailers::EventMailer.should_receive(:deliver_region_manager_notification)
      
      post :create, {:event => @event.attributes}
    end
    
    it 'should redisplay event create form when event data is invalid' do
      post :create, {:event => @event.attributes.merge(:name => '')}
      response.should render_template(:new)
    end
  end
  
  it 'should not be accessible to guests' do
    post :create, {:event => @event.attributes}
    response.should redirect_to(root_path)
  end
end

describe EventsController, 'show' do
  it 'should load event by event URL' do
    event = Factory(:event)
    get :show, {:id => event.url}
    response.should be_success
    assigns[:event].should eql(event)
  end
  
  it 'should not show unpublished event to public users' do
    event = Factory(:event, :status => Event::STATUS[:new])
    get :show, {:id => event.url}
    response.should redirect_to(root_path)
  end
  
  it 'should show unpublished event to event owner' do
    user = Factory.create(:user)
    activate_authlogic
    UserSession.create user
    
    event = Factory(:event, :status => Event::STATUS[:new], :manager => user)
    
    get :show, {:id => event.url}
    response.should be_success
    assigns[:event].should eql(event)
  end
end

describe EventsController, 'map' do
  it 'should be accessible to all users' do
    get :map
    response.should be_success
  end
end
