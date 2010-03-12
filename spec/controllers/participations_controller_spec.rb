require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParticipationsController do
  describe 'index' do
    it 'should be denied for public users and redirect to home' do
      ep = Factory(:event_participant)
      get :index, {:event_id => ep.event.url}      
      response.should redirect_to(root_path)
    end
    
    it 'should assign list of participants associated with event to regional manager' do
      ep = Factory(:event_participant)

      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:regional_manager], manager, ep.event.location_address_county)
      
      get :index, {:event_id => ep.event.url}      
      assigns[:event_participants].should include(ep)      
    end

    it 'should be denied to see list of participants associated with event to different regional manager' do
      ep = Factory(:event_participant)

      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:regional_manager], manager, Factory(:county))
      
      get :index, {:event_id => ep.event.url}      
      assigns[:event_participants].should_not include(ep)      
    end
    
    it 'should assign list of participants associated with event to account manager' do
      ep = Factory(:event_participant)

      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:account_manager], manager, Account.current)
      
      get :index, {:event_id => ep.event.url}      
      assigns[:event_participants].should include(ep)      
    end

    it 'should assign list of participants associated with event to event manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      ep = Factory(:event_participant)
      Role.grant_role(Role::ROLE[:event_manager], manager, ep.event)
      
      get :index, {:event_id => ep.event.url}      
      assigns[:event_participants].should include(ep)
    end

    it 'should not assign list of participants associated with event to different event manager' do
      manager = Factory.create(:user)
      manager2 = Factory.create(:user)
      
      activate_authlogic and UserSession.create(manager)
      ep = Factory(:event_participant)
      Role.grant_role(Role::ROLE[:event_manager], manager2, ep.event)
      
      get :index, {:event_id => ep.event.url}      
      assigns[:event_participants].should_not include(ep)
    end
  end
  
  describe 'create' do
    before(:each) do
      @event = Factory(:event)
      @ep = Factory.build(:event_participant)
    end
    
    it 'should create event participation record when submitted data is valid' do
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
      response.should redirect_to(event_path(@event))
    end
    
    it 'should send e-mail to all registered participants after successful registration' do
      Mailers::EventMailer.should_receive(:deliver_participant_notification)
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
    end
    
    it 'should send e-mail to event managers after successful registration' do
      Role.grant_role(Role::ROLE[:event_manager], Factory(:user), @event)
      Mailers::EventMailer.should_receive(:deliver_manager_participation_notification).twice
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
    end
    
    it 'should send e-mail to participant friends if their e-mails are supplied' do
      @ep.tellafriend_emails = 'a@example.com,b@example.com,c@example.com'
      Mailers::EventMailer.should_receive(:deliver_tell_friend_notification).exactly(3).times
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
    end
    
    it 'should show register screen when registration info is invalid' do
      @ep.firstname = nil
      @ep.lastname = nil
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
      response.should render_template(:new)
    end
  end
  
  describe 'editing participation from encoded url' do
    it 'should load participation when encoded url is valid' do
      ep = Factory(:event_participant)
      
      get :show, {:event_id => ep.event.url, :id => UrlStore.encode(ep.id)}
      response.should be_success
      response.should render_template(:show)
      assigns[:event_participant].should eql(ep)
    end
    
    it 'should redirect to event view when encoded url invalid' do
      ep = Factory(:event_participant)
      
      get :show, {:event_id => ep.event.url, :id => ep.id}
      response.should redirect_to(event_path(ep.event))
    end
  end
end
