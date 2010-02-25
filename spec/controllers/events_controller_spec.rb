require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController, 'index' do
  it 'should show a list of events' do
    events = Array.new(10) { |i| Factory.create(:event) }
    
    get :index
    assigns[:events].each { |e| events.should include(e) }
  end
  
  it 'should be accessible by all users' do
<<<<<<< HEAD
    event = Factory(:event, :status => Event::STATUS[:new])
    get :show, {:id => event.url}
    response.should redirect_to(root_path)
    #assigns[:event].should eql(event)
=======
    get :index
    response.should be_success
>>>>>>> af5713103105d23df8d74164f063f0da8143d32e
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
  
  context 'with authenticated users' do
    before(:each) do
      @user = Factory.create(:user)
      activate_authlogic
      UserSession.create @user
    end
    
    it 'should create event and assign current user as manager when event is valid' do
      event = Factory.build(:event)
      post :create, {:event => event.attributes}
      response.should redirect_to(events_path)
      assigns[:event].manager.should eql(@user)
    end
    
    it 'should send e-mail notification to region manager'
    
    it 'should redisplay event create form when event data is invalid' do
      event = Factory.build(:event)
      post :create, {:event => event.attributes.merge(:name => '')}
      response.should render_template(:new)
    end
  end
  
  it 'should not be accessible to guests' do
    event = Factory.build(:event)
    post :create, {:event => event.attributes}
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
<<<<<<< HEAD
    event = Factory(:event)
=======
    event = Factory(:event, :status => Event::STATUS[:new])
>>>>>>> af5713103105d23df8d74164f063f0da8143d32e
    get :show, {:id => event.url}
    response.should redirect_to(root_path)
  end
  
<<<<<<< HEAD
  it 'should show published event to event owner'
  
  it 'should show unpublished event to event owner'
=======
  it 'should show unpublished event to event owner' do
    user = Factory.create(:user)
    activate_authlogic
    UserSession.create user
    
    event = Factory(:event, :status => Event::STATUS[:new], :manager => user)
    get :show, {:id => event.url}
    response.should be_success
    assigns[:event].should eql(event)
  end
>>>>>>> af5713103105d23df8d74164f063f0da8143d32e
end
