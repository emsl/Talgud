require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController do
  
  describe 'index' do
    it 'should show a list of events' do
      events = Array.new(10) { |i| Factory.create(:event) }
      
      get :index, {:format => 'html'}
      assigns[:events].each { |e| events.should include(e) }
    end
    
    it 'should be accessible by all users' do
      get :index
      response.should be_success
    end
    
    it 'should filter and list events in xml format' do
      e1 = Factory.create(:event, :event_type => Factory.create(:event_type))
      e2 = Factory.create(:event, :event_type => e1.event_type)
      e3 = Factory.create(:event, :location_address_county => e2.location_address_county, 
        :location_address_municipality => e2.location_address_municipality, :event_type => Factory.create(:event_type))
      
      get :index, {:format => 'xml', :county => e2.location_address_county.id, :event_type => e2.event_type.id}
      response.content_type.should eql('application/xml')
      response.should have_tag('events') do
        with_tag('event') do
          with_tag('code', e2.code)
        end
      end
    end
  end
  
  describe 'filter' do
    before(:each) do
      @first_manager = Factory(:user, :firstname => 'Mati', :lastname => 'Kuusk')
      @second_manager = Factory(:user, :firstname => 'Laine', :lastname => 'Mägi')
      @third_manager = Factory(:user, :firstname => 'Mati', :lastname => 'Kägi')
      @e1 = Factory.create(:event, :event_type => Factory.create(:event_type), :manager => @first_manager)
      @e2 = Factory.create(:event, :event_type => @e1.event_type, :manager => @second_manager)
      @e3 = Factory.create(:event, :location_address_county => @e2.location_address_county,
        :location_address_municipality => @e2.location_address_municipality, :event_type => Factory.create(:event_type),
      :languages => @e1.languages, :manager => @third_manager)
      
      Role.grant_role(Role::ROLE[:event_manager], @e1.manager, @e1)
      Role.grant_role(Role::ROLE[:event_manager], @e2.manager, @e2)
      Role.grant_role(Role::ROLE[:event_manager], @e3.manager, @e3)
    end    
    
    it 'should filter index' do      
      get :index, {:county => @e2.location_address_county.id, :event_type => @e2.event_type.id, :format => 'html'}
      assigns[:events].should include(@e2)
      assigns[:events].should_not include(@e1, @e3)
      
      get :index, {:county => @e2.location_address_county.id, :format => 'html'}
      assigns[:events].should include(@e2, @e3)
      assigns[:events].should_not include(@e1)
      
      get :index, {:event_type => @e1.event_type.id, :format => 'html'}
      assigns[:events].should include(@e1, @e2)
      assigns[:events].should_not include(@e3)

      get :index, {:language_code => @e1.languages.first.code, :format => 'html'}
      assigns[:events].should include(@e1, @e3)
      assigns[:events].should_not include(@e2)      

      get :index, {:event_code => @e1.code, :format => 'html'}
      assigns[:events].should include(@e1)
      assigns[:events].should_not include(@e2, @e3)      

      get :index, {:manager_name => @first_manager.firstname, :format => 'html'}
      assigns[:events].should include(@e1)
      assigns[:events].should_not include(@e2, @e3)      
    end
    
    it 'should filter latest' do      
      get :latest, {:county => @e2.location_address_county.id, :event_type => @e2.event_type.id, :format => 'html'}
      assigns[:events].should include(@e2)
      assigns[:events].should_not include(@e1, @e3)
      
      get :latest, {:county => @e2.location_address_county.id, :format => 'html'}
      assigns[:events].should include(@e2, @e3)
      assigns[:events].should_not include(@e1)
      
      get :latest, {:event_type => @e1.event_type.id, :format => 'html'}
      assigns[:events].should include(@e1, @e2)
      assigns[:events].should_not include(@e3)

      get :latest, {:language_code => @e1.languages.first.code, :format => 'html'}
      assigns[:events].should include(@e1, @e3)
      assigns[:events].should_not include(@e2)      

      get :latest, {:event_code => @e1.code, :format => 'html'}
      assigns[:events].should include(@e1)
      assigns[:events].should_not include(@e2, @e3)      

      get :latest, {:manager_name => @first_manager.firstname, :format => 'html'}
      assigns[:events].should include(@e1)
      assigns[:events].should_not include(@e2, @e3)      

      get :latest, {:limit => 2, :format => 'json'}
      assigns[:events].size.should eql(2)

      get :latest, {:limit => 2, :format => 'html'}
      assigns[:events].size.should eql(2)
    end
    
    it 'should filter map' do
      get :map, {:county => @e2.location_address_county.id, :event_type => @e2.event_type.id, :format => 'json'}
      assigns[:events].should include(@e2)
      assigns[:events].should_not include(@e1, @e3)
      
      get :map, {:county => @e2.location_address_county.id, :format => 'json'}
      assigns[:events].should include(@e2, @e3)
      assigns[:events].should_not include(@e1)
      
      get :map, {:event_type => @e1.event_type.id, :format => 'json'}
      assigns[:events].should include(@e1, @e2)
      assigns[:events].should_not include(@e3)

      get :map, {:language_code => @e1.languages.first.code, :format => 'json'}
      assigns[:events].should include(@e1, @e3)
      assigns[:events].should_not include(@e2)      

      get :map, {:event_code => @e1.code, :format => 'json'}
      assigns[:events].should include(@e1)
      assigns[:events].should_not include(@e2, @e3)      

      get :map, {:manager_name => @first_manager.firstname, :format => 'json'}
      assigns[:events].should include(@e1)
      assigns[:events].should_not include(@e2, @e3)            
    end    
  end  
  
  
  describe 'new' do
    it 'should not be displayed when user is not logged in' do
      get :new
      response.should redirect_to(root_path)
    end
    
    it 'should be displayed when user is logged in' do
      activate_authlogic and UserSession.create(Factory.create(:user))
        
      get :new
      response.should be_success
    end
  end
  
  describe 'create' do
    before(:each) do
      @user = Factory.create(:user)
      @event = Factory.build(:event)
    end
    
    context 'with authenticated users' do
      before(:each) do
        activate_authlogic and UserSession.create(@user)
      end
      
      it 'should create event and assign current user as manager when event is valid' do
        post :create, {:event => @event.attributes.merge('language_ids' => [Factory(:language).id])}
        response.should redirect_to(event_path(assigns[:event]))
        assigns[:event].managers.should include(@user)
      end
      
      it 'should send e-mail notification to region manager' do
        municipality = Factory(:municipality)
        regional_manager = Factory(:user)
        Role.grant_role(Role::ROLE[:regional_manager], regional_manager, municipality.county)
        
        @event.location_address_county = municipality.county
        @event.location_address_municipality = municipality
        Mailers::EventMailer.should_receive(:deliver_region_manager_notification)
        
        post :create, {:event => @event.attributes.merge('language_ids' => [Factory(:language).id])}
      end
      
      it 'should redisplay event create form when event data is invalid' do
        post :create, {:event => @event.attributes.merge('name' => '')}
        response.should render_template(:new)
      end
    end
    
    it 'should not be accessible to guests' do
      post :create, {:event => @event.attributes}
      response.should redirect_to(root_path)
    end
  end
  
  describe 'show' do
    it 'should load event by event URL' do
      [Event::STATUS[:published], Event::STATUS[:registration_open], Event::STATUS[:registration_closed]].each do |status|
        event = Factory(:event, :status => status)
        get :show, {:id => event.url}
        response.should be_success
        assigns[:event].should eql(event)
      end
    end
    
    it 'should not show unpublished event to public users' do
      event = Factory(:event, :status => Event::STATUS[:new])
      get :show, {:id => event.url}
      response.should redirect_to(root_path)
    end
    
    it 'should show unpublished event to event manager' do
      user = Factory.create(:user)
      activate_authlogic and UserSession.create(user)
      
      event = Factory(:event, :status => Event::STATUS[:new], :manager => user)
      Role.grant_role(Role::ROLE[:event_manager], event.manager, event)
      
      get :show, {:id => event.url}
      response.should be_success
      assigns[:event].should eql(event)
    end
  end
  
  describe 'edit' do
    it 'should be accessible for users in event manager role' do
      user = Factory.create(:user)
      activate_authlogic and UserSession.create(user)

      another_user = Factory.create(:user)
      
      event = Factory(:event, :status => Event::STATUS[:new], :manager => another_user)
      get :edit, {:id => event.url}
      response.should redirect_to(root_path)
      
      Role.grant_role(Role::ROLE[:event_manager], user, event)
      get :edit, {:id => event.url}
      response.should be_success
      assigns[:event].should eql(event)
    end
  end
  
  describe 'update' do
    before(:each) do
      @user = Factory.create(:user)
      activate_authlogic and UserSession.create(@user)
    end
    
    it 'should be accessible for users in event manager role' do
      another_user = Factory.create(:user)
      
      event = Factory(:event, :status => Event::STATUS[:new], :manager => another_user)
      post :update, {:id => event.url, :event => event.attributes}
      response.should redirect_to(root_path)
      
      Role.grant_role(Role::ROLE[:event_manager], @user, event)
      
      post :update, {:id => event.url, :event => event.attributes}
      response.should redirect_to(event_path(event))
    end
    
    it 'should update event with valid attributes' do
      event = Factory(:event, :manager => @user)
      Role.grant_role(Role::ROLE[:event_manager], event.manager, event)
      post :update, {:id => event.url, :event => event.attributes}
      response.should redirect_to(event_path(event))
    end
    
    it 'should not update event with invalid attributes and render edit view again' do
      event = Factory(:event, :manager => @user)
      Role.grant_role(Role::ROLE[:event_manager], event.manager, event)
      
      post :update, {:id => event.url, :event => event.attributes.merge('name' => '')}
      response.should render_template(:new)
    end
  end
  
  describe 'map' do
    it 'should be accessible to all users' do
      get :map
      response.should be_success
    end
  end  
end
