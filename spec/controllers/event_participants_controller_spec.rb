require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventParticipantsController do
  describe 'index' do
    before(:each) do
      @ep = Factory(:event_participant)
    end

    it 'should be denied for public users and redirect to home' do
      get :index, {:event_id => @ep.event.url}
      response.should redirect_to(login_path)
    end

    it 'should redirect to home if event url is invalid' do
      get :index, {:event_id => 'blaah-event'}
      response.should redirect_to(login_path)
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
      response.should redirect_to(login_path)
    end

    it 'should delete participant if requested by event manager' do
      EventParticipant.should_receive(:find).and_return(@ep)
      @ep.should_receive(:destroy)

      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)

      delete :destroy, {:event_id => @ep.event.url, :id => @ep.id}
      response.should redirect_to(event_event_participants_path(@ep.event))
    end

    it 'should not be accessible by another event manager' do
      EventParticipant.should_not_receive(:find)

      manager = Factory.create(:user)
      manager2 = Factory.create(:user)
      activate_authlogic and UserSession.create(manager2)
      Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)

      delete :destroy, {:event_id => @ep.event.url, :id => @ep.id}
      response.should redirect_to(login_path)
    end
  end

  describe 'new_mail' do
    before(:each) do
      @ep = Factory(:event_participant)
    end

    it 'should render new email sending form' do
      user = Factory(:user)
      activate_authlogic and UserSession.create(user)
      Role.grant_role(Role::ROLE[:event_manager], user, @ep.event)

      get :new_mail, {:event_id => @ep.event.url}
      assigns[:mail].should_not be_nil
      assigns[:event].should eql(@ep.event)
      # TODO: strange case, response.should be_success returns false
      #response.status.should eql("200 OK")
      response.should be_success
    end

    it 'should not by accessible by public users and redirect to login path' do
      get :new_mail, {:event_id => @ep.event.url}
      assigns[:mail].should be_nil
      response.should redirect_to(login_path)
    end

    it 'should not by accessible by another event manager and redirect to login path' do
      user = Factory(:user)
      activate_authlogic and UserSession.create(user)

      get :new_mail, {:event_id => @ep.event.url}
      assigns[:mail].should be_nil
      response.should redirect_to(login_path)
    end
  end

  describe 'create_mail' do
    before(:each) do
      @ep = Factory(:event_participant)
    end

    it 'should send email to event participants' do
      user = Factory(:user)
      activate_authlogic and UserSession.create(user)
      Role.grant_role(Role::ROLE[:event_manager], user, @ep.event)
      Mailers::EventMailer.should_receive(:deliver_participants_manager_notification)
      
      post :create_mail, {:event_id => @ep.event.url, :mail => {:subject => 'test', :message => 'message'}}
      assigns[:mail].should_not be_nil
      assigns[:mail].should be_valid
      
      response.should redirect_to(event_event_participants_path(@ep.event))
    end

    it 'should render form and not send email on invalid email' do
      user = Factory(:user)
      activate_authlogic and UserSession.create(user)
      Role.grant_role(Role::ROLE[:event_manager], user, @ep.event)
      
      post :create_mail, {:event_id => @ep.event.url, :mail => {:subject => 'test', :message => nil}}
      assigns[:mail].should_not be_nil
      assigns[:mail].should be_invalid
      
      response.should render_template(:new_mail)
      Mailers::EventMailer.should_not_receive(:deliver_participants_manager_notification)
    end

    it 'should not by accessible by public users and redirect to login path' do
      post :create_mail, {:event_id => @ep.event.url, :subject => 'test', :message => 'message'}
      assigns[:mail].should be_nil
      response.should redirect_to(login_path)
    end

    it 'should not by accessible by another event manager and redirect to login path' do
      user = Factory(:user)
      activate_authlogic and UserSession.create(user)

      post :create_mail, {:event_id => @ep.event.url, :subject => 'test', :message => 'message'}
      assigns[:mail].should be_nil
      response.should redirect_to(login_path)
    end
  end

  describe 'edit' do
    before(:each) do
      @ep = Factory(:event_participant)
    end

    it 'should show edit form to event manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:event_manager], manager, @ep.event)

      get :edit, {:event_id => @ep.event.url, :id => @ep.id}
      assigns[:event].should eql(@ep.event)
      assigns[:event_participant].should eql(@ep)
    end

    it 'should not accesible by another event manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      event = Factory(:event, :manager => manager)

      get :edit, {:event_id => @ep.event.url, :id => @ep.id}
      assigns[:event].should be_nil
      response.should redirect_to(login_path)
    end

    it 'should not accesible by public user' do
      EventParticipant.should_not_receive(:find)
      get :edit, {:event_id => @ep.event.url, :id => @ep.id}
      response.should redirect_to(login_path)
    end
  end
end
