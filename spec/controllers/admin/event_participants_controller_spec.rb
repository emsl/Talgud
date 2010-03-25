require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::EventParticipantsController do
  describe 'index' do
    before(:each) do
      @ep = Factory(:event_participant)
    end
    
    it 'should be denied for public users and redirect to home' do
      get :index, {:event_id => @ep.event.id}
      response.should redirect_to(admin_login_path)
    end

    # it 'should assign list of participants associated with event to regional manager' do
    #   manager = Factory.create(:user)
    #   activate_authlogic and UserSession.create(manager)
    #   Role.grant_role(Role::ROLE[:regional_manager], manager, @ep.event.location_address_county)
    # 
    #   get :index, {:event_id => @ep.event.id}
    #   response.should be_success
    #   assigns[:event_participants].should include(@ep)
    # end

    it 'should be denied to see list of participants associated with event to different regional manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:regional_manager], manager, Factory(:county))

      proc {get :index, {:event_id => @ep.event.id}}.should raise_error(ActiveRecord::RecordNotFound)
    end

    # it 'should assign list of participants associated with event to account manager' do
    #   manager = Factory.create(:user)
    #   activate_authlogic and UserSession.create(manager)
    #   Role.grant_role(Role::ROLE[:account_manager], manager, Account.current)
    # 
    #   get :index, {:event_id => @ep.event.id}
    #   assigns[:event_participants].should include(@ep)
    # end
    # 
    # it 'should assign list of participants associated with event to event manager' do
    #   manager = Factory.create(:user)
    #   activate_authlogic and UserSession.create(manager)
    #   Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)
    # 
    #   get :index, {:event_id => @ep.event.id}
    #   assigns[:event_participants].should include(@ep)
    # end

    it 'should not assign list of participants associated with event to different event manager' do
      manager = Factory.create(:user)
      manager2 = Factory.create(:user)

      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:event_manager], manager2, @ep.event)

      proc {get :index, {:event_id => @ep.event.id}}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  describe 'destroy' do
    before(:each) do
      @ep = Factory(:event_participant)
    end
    
    it 'should be denied for public users and redirect to home' do
      delete :destroy, {:event_id => @ep.event.id, :id => @ep.id}
      response.should redirect_to(admin_login_path)
    end
    
    # it 'should delete participant if requested by event manager' do
    #   EventParticipant.should_receive(:find).and_return(@ep)
    #   @ep.should_receive(:destroy)
    #   
    #   manager = Factory.create(:user)
    #   activate_authlogic and UserSession.create(manager)
    #   Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)
    # 
    #   delete :destroy, {:event_id => @ep.event.id, :id => @ep.id}
    #   response.should redirect_to(event_participations_path(@ep.event))
    # end
    
    it 'should not be accessible by another event manager' do
      EventParticipant.should_not_receive(:find)
      
      manager = Factory.create(:user)
      manager2 = Factory.create(:user)
      activate_authlogic and UserSession.create(manager2)
      Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)

      proc { delete :destroy, {:event_id => @ep.event.id, :id => @ep.id} }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'new' do
    it 'should not be displayed when user is not logged in' do
      event = Factory(:event)
      get :new, {:event_id => event.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be redirected to login path when user is logged in as not admin' do
      user = Factory.create(:user)
      activate_authlogic and UserSession.create(user)
      event = Factory(:event, :manager => user)
      get :new, {:event_id => event.id}
        
      response.should redirect_to(admin_login_path)
    end

    it 'should be displayed when user is logged in as admin' do
      admin = Factory.create(:user)
      activate_authlogic and UserSession.create(admin)
      Role.grant_role(Role::ROLE[:account_manager], admin, Account.current)
        
      event = Factory(:event)
      get :new, {:event_id => event.id}

      response.should be_success
    end
  end
  
  describe 'create for authenticated user' do
    before(:each) do
      @event = Factory(:event)
      @ep = Factory.build(:event_participant)
      admin = Factory.create(:user)
      activate_authlogic and UserSession.create(admin)
      Role.grant_role(Role::ROLE[:account_manager], admin, Account.current)      
    end

    it 'should create event participation record when submitted data is valid' do
      post :create, {:event_id => @event.id, :event_participant => @ep.attributes}
      response.should redirect_to(admin_event_participations_path(@event.id))
    end

    it 'should send e-mail to registrant after successful registration' do
      Mailers::EventMailer.should_receive(:deliver_participant_notification)
      post :create, {:event_id => @event.id, :event_participant => @ep.attributes}
    end
    
    it 'should send e-mail to invited participants after successful registration' do
      Mailers::EventMailer.should_receive(:deliver_invite_participant_notification).twice
      children = {0 => Factory.build(:event_participant).attributes, 1 => Factory.build(:event_participant).attributes}
      post :create, {:event_id => @event.id, :event_participant => @ep.attributes.merge(:children_attributes => children)}
    end

    it 'should send e-mail to event managers after successful registration' do
      Role.grant_role(Role::ROLE[:event_manager], Factory(:user), @event)
      Mailers::EventMailer.should_receive(:deliver_manager_participation_notification).twice
      post :create, {:event_id => @event.id, :event_participant => @ep.attributes}
    end

    it 'should show register screen when registration info is invalid' do
      @ep.firstname = nil
      @ep.lastname = nil
      post :create, {:event_id => @event.id, :event_participant => @ep.attributes}
      response.should render_template(:new)
    end
  end  

  describe 'show' do
    it 'should load participation for authorized users' do
      admin = Factory.create(:user)
      activate_authlogic and UserSession.create(admin)
      Role.grant_role(Role::ROLE[:account_manager], admin, Account.current)
      ep = Factory(:event_participant)

      get :show, {:event_id => ep.event.id, :id => ep.id}
      response.should be_success
      response.should render_template(:show)
      assigns[:event_participant].should eql(ep)
    end

    it 'should be denied and redirect to login path for public users' do
      ep = Factory(:event_participant)
      get :show, {:event_id => ep.event.id, :id => ep.id}
      response.should redirect_to(admin_login_path)
    end
  end
end
