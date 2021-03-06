require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::EventsController do

  describe 'index' do
    it 'should be denied for public users' do
      events = Array.new(10) { |i| Factory(:event) }
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should show a list of events for account manager' do
      account_manager = Factory(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      events = Array.new(10) { |i| Factory(:event) }
      get :index, {:format => 'html'}
      assigns[:events].each { |e| events.should include(e) }
    end

    it 'should show a list of events for regional manager' do
      regional_manager = Factory(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, Account.current)

      events = Array.new(10) do |i|
        event = Factory(:event)
        Role.grant_role(Role::ROLE[:regional_manager], regional_manager, event.location_address_county)
        event
      end
      get :index, {:format => 'html'}
      assigns[:events].each { |e| events.should include(e) }
    end

    it 'should be denied for different regional manager' do
      county = Factory(:county)
      regional_manager = Factory(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, county)

      events = Array.new(10) { |i| Factory(:event) }
      get :index, {:format => 'html'}
      assigns[:events].should be_empty
    end
    
    it 'should filter events if requested' do
      account_manager = Factory(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)
      
      e1 = Factory(:event, :event_type => Factory(:event_type))
      e2 = Factory(:event, :event_type => e1.event_type)
      e3 = Factory(:event, :location_address_county => e2.location_address_county,
        :location_address_municipality => e2.location_address_municipality, :event_type => Factory(:event_type))
      
      get :index, {:search => {:location_address_county_id => e2.location_address_county.id}, :format => 'html'}
      assigns[:events].should include(e2, e3)
      assigns[:events].should_not include(e1)

      get :index, {:format => 'html'}
      assigns[:events].should include(e2, e3, e1)
       
      get :index, {:search => {:event_type_id => e1.event_type.id}, :format => 'html'}
      assigns[:events].should include(e1, e2)
      assigns[:events].should_not include(e3)
    end
    
    
    it 'should filter and list events in xml format' do
      account_manager = Factory(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)
      
      e1 = Factory(:event, :event_type => Factory(:event_type))
      e2 = Factory(:event, :event_type => e1.event_type)
      e3 = Factory(:event, :location_address_county => e2.location_address_county, 
        :location_address_municipality => e2.location_address_municipality, :event_type => Factory(:event_type))
      
      get :index, {:format => 'xml', :search => {:location_address_county_id => e2.location_address_county.id}}
      response.content_type.should eql('application/xml')
      response.should have_tag('events') do
        with_tag('event') do
          without_tag('code', e1.code)
          with_tag('code', e2.code)
          with_tag('code', e3.code)
        end
      end
    end
    
  end

  describe 'map' do
    it 'should be denied for public users' do
      events = Array.new(10) { |i| Factory(:event) }
      get :map
      response.should redirect_to(admin_login_path)
    end

    it 'should show map of events for account manager' do
      account_manager = Factory(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      events = Array.new(10) { |i| Factory(:event) }
      get :map
      assigns[:events].each { |e| events.should include(e) }
    end

    it 'should show a list of events for regional manager' do
      regional_manager = Factory(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, Account.current)

      events = Array.new(10) do |i|
        event = Factory(:event)
        Role.grant_role(Role::ROLE[:regional_manager], regional_manager, event.location_address_county)
        event
      end
      get :map
      assigns[:events].each { |e| events.should include(e) }
    end

    it 'should be denied for different regional manager' do
      county = Factory(:county)
      regional_manager = Factory(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, county)

      events = Array.new(10) { |i| Factory(:event) }
      get :map
      assigns[:events].should be_empty
    end
  end

  describe 'show' do
    it 'should show event details if user is account manager' do
      account_manager = Factory(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      event = Factory(:event)
      Role.grant_role(Role::ROLE[:event_manager], event.manager, event)
      
      get :show, {:id => event.id}
      response.should be_success
      assigns[:event].should eql(event)
    end

    it 'should show event details in xml format if requested' do
      account_manager = Factory(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      event = Factory(:event)
      get :show, {:format => 'xml', :id => event.id}
      response.content_type.should eql('application/xml')
      response.should have_tag('event') do
        with_tag('code', event.code)
      end
    end
    
    it 'should show event details if user is regional manager' do
      regional_manager = Factory(:user)
      activate_authlogic and UserSession.create(regional_manager)
      event = Factory(:event)
      
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, event.location_address_county)
      get :show, {:id => event.id}
      response.should be_success
      assigns[:event].should eql(event)
    end

    it 'should be denied for public users' do
      another_user = Factory(:user)
      event = Factory(:event, :manager => another_user)

      get :show, {:id => event.id}
      response.should redirect_to(admin_login_path)
    end

    it 'should show event to event manager' do
      user = Factory(:user)
      activate_authlogic and UserSession.create(user)
      event = Factory(:event, :status => Event::STATUS[:new], :manager => user)
      Role.grant_role(Role::ROLE[:event_manager], event.manager, event)      

      get :show, {:id => event.id} 
      assigns[:event].should eql(event)
    end
  end

  describe 'update' do
    it 'should update event if user is account manager' do
      account_manager = Factory(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      event = Factory(:event)
      post :update, {:id => event.id, :event => event.attributes}
      response.should redirect_to(admin_event_path(event.id))      
    end

    it 'should update event if user is regional manager' do
      regional_manager = Factory(:user)
      activate_authlogic and UserSession.create(regional_manager)
      event = Factory(:event)

      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, event.location_address_county)
      post :update, {:id => event.id, :event => event.attributes}
      response.should redirect_to(admin_event_path(event.id))
    end

    it 'should be denied to update event if user is different regional manager' do
      county = Factory(:county)
            
      regional_manager = Factory(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, county)

      event = Factory(:event)
      proc { post :update, {:id => event.id, :event => event.attributes} }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should be denied for unauthorized users' do
      user = Factory(:user)
      event = Factory(:event, :status => Event::STATUS[:new], :manager => user)
      post :update, {:id => event.id, :event => event.attributes}
      response.should redirect_to(admin_login_path)
    end
  end
end
