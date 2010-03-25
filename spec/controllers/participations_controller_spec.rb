require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParticipationsController do
  describe 'index' do
    before(:each) do
      @ep = Factory(:event_participant)
    end
    
    it 'should be denied for public users and redirect to home' do
      get :index, {:event_id => @ep.event.url}
      response.should redirect_to(root_path)
    end

    it 'should redirect to home if event url is invalid' do
      get :index, {:event_id => 'blaah-event'}
      response.should redirect_to(root_path)
    end

    it 'should assign list of participants associated with event to regional manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:regional_manager], manager, @ep.event.location_address_county)

      get :index, {:event_id => @ep.event.url}
      assigns[:event_participants].should include(@ep)
    end

    it 'should be denied to see list of participants associated with event to different regional manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:regional_manager], manager, Factory(:county))

      get :index, {:event_id => @ep.event.url}
      assigns[:event_participants].should be_nil
    end

    it 'should assign list of participants associated with event to account manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:account_manager], manager, Account.current)

      get :index, {:event_id => @ep.event.url}
      assigns[:event_participants].should include(@ep)
    end

    it 'should assign list of participants associated with event to event manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)

      get :index, {:event_id => @ep.event.url}
      assigns[:event_participants].should include(@ep)
    end

    it 'should not assign list of participants associated with event to different event manager' do
      manager = Factory.create(:user)
      manager2 = Factory.create(:user)

      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:event_manager], manager2, @ep.event)

      get :index, {:event_id => @ep.event.url}
      assigns[:event_participants].should be_nil
    end
  end
  
  describe 'destroy' do
    before(:each) do
      @ep = Factory(:event_participant)
    end
    
    it 'should be denied for public users and redirect to home' do
      delete :destroy, {:event_id => @ep.event.url, :id => @ep.id}
      response.should redirect_to(root_path)
    end
    
    it 'should delete participant if requested by event manager' do
      EventParticipant.should_receive(:find).and_return(@ep)
      @ep.should_receive(:destroy)
      
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)

      delete :destroy, {:event_id => @ep.event.url, :id => @ep.id}
      response.should redirect_to(event_participations_path(@ep.event))
    end
    
    it 'should not be accessible by another event manager' do
      EventParticipant.should_not_receive(:find)
      
      manager = Factory.create(:user)
      manager2 = Factory.create(:user)
      activate_authlogic and UserSession.create(manager2)
      Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)

      delete :destroy, {:event_id => @ep.event.url, :id => @ep.id}
      response.should redirect_to(root_path)
    end
  end

  describe 'new' do
    it 'should redirect to events path if there are no vacancies' do
      event = Factory(:event, :max_participants => 1)
      ep = Factory(:event_participant, :event => event)
      
      get :new, {:event_id => event.url}
      response.should redirect_to(event_path(event))
    end
  end
  
  describe 'create' do
    before(:each) do
      @event = Factory(:event)
      @ep = Factory.build(:event_participant)
    end

    it 'should create event participation record when submitted data is valid' do
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
      response.should redirect_to(confirmation_event_participation_path(@event, UrlStore.encode(assigns[:event_participant].id)))
    end

    it 'should send e-mail to registrant after successful registration' do
      Mailers::EventMailer.should_receive(:deliver_participant_notification)
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
    end
    
    it 'should send e-mail to invited participants after successful registration' do
      Mailers::EventMailer.should_receive(:deliver_invite_participant_notification).twice
      children = {0 => Factory.build(:event_participant).attributes, 1 => Factory.build(:event_participant).attributes}
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes.merge(:children_attributes => children)}
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

    it 'should redirect to participation show when encoded url is valid' do
      ep = Factory(:event_participant)
      id = UrlStore.encode(ep.id)
      get :redirect, {:id => id}
      response.should redirect_to(event_participation_path(ep.event, id))
    end

    it 'should redirect to event view when encoded url invalid' do
      ep = Factory(:event_participant)

      get :show, {:event_id => ep.event.url, :id => ep.id}
      response.should redirect_to(event_path(ep.event))
    end
  end
  
  describe 'updating participation from encoded url' do
    before(:each) do
      @event = Factory(:event)
      @ep = Factory(:event_participant, :children => [Factory(:event_participant), Factory(:event_participant)])
    end
    
    it 'should send e-mail to freshly invited participants after successful save' do
      Mailers::EventMailer.should_receive(:deliver_invite_participant_notification).twice

      children = {0 => Factory.build(:event_participant).attributes, 1 => Factory.build(:event_participant).attributes}
      put :update, {:event_id => @event.url, :id => UrlStore.encode(@ep.id), :event_participant => @ep.attributes.merge(:children_attributes => children)}
      
      response.should redirect_to(event_path(@event.url))
    end
  end
end
