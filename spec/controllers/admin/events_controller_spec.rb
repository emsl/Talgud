require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::EventsController do

  describe 'index' do
    it 'should be denied for public users' do
      events = Array.new(10) { |i| Factory.create(:event) }
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should show a list of events for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      events = Array.new(10) { |i| Factory.create(:event) }
      get :index
      assigns[:events].each { |e| events.should include(e) }
    end

    it 'should be denied for different account manager' do
      different_account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(different_account_manager)
      Role.grant_role(Role::ROLE[:account_manager], different_account_manager, Factory.create(:account))

      events = Array.new(10) { |i| Factory.create(:event) }
      get :index
      assigns[:events].should be_empty
    end

    it 'should show a list of events for regional manager' do
      regional_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, Account.current)

      events = Array.new(10) do |i|
        event = Factory.create(:event)
        Role.grant_role(Role::ROLE[:regional_manager], regional_manager, event.location_address_county)
        event
      end
      get :index
      assigns[:events].each { |e| events.should include(e) }
    end

    it 'should be denied for different regional manager' do
      county = Factory(:county)
      regional_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, county)

      events = Array.new(10) { |i| Factory.create(:event) }
      get :index
      assigns[:events].should be_empty
    end
  end

  describe 'map' do
    it 'should be denied for public users' do
      events = Array.new(10) { |i| Factory.create(:event) }
      get :map
      response.should redirect_to(admin_login_path)
    end

    it 'should show map of events for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      events = Array.new(10) { |i| Factory.create(:event) }
      get :map
      assigns[:events].each { |e| events.should include(e) }
    end

    it 'should be denied for different account manager' do
      different_account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(different_account_manager)
      Role.grant_role(Role::ROLE[:account_manager], different_account_manager, Factory.create(:account))

      events = Array.new(10) { |i| Factory.create(:event) }
      get :map
      assigns[:events].should be_empty
    end

    it 'should show a list of events for regional manager' do
      regional_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, Account.current)

      events = Array.new(10) do |i|
        event = Factory.create(:event)
        Role.grant_role(Role::ROLE[:regional_manager], regional_manager, event.location_address_county)
        event
      end
      get :map
      assigns[:events].each { |e| events.should include(e) }
    end

    it 'should be denied for different regional manager' do
      county = Factory(:county)
      regional_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(regional_manager)
      Role.grant_role(Role::ROLE[:regional_manager], regional_manager, county)

      events = Array.new(10) { |i| Factory.create(:event) }
      get :map
      assigns[:events].should be_empty
    end
  end

  describe 'show' do
    it 'should show event details if user is account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      event = Factory.create(:event)
      get :show, {:id => event.id}
      response.should be_success
      assigns[:event].should eql(event)
    end

    it 'should deny details if user is different account manager' do
      pending 'mingi jama on siin, homme vaatab edasi' do
        different_account_manager = Factory.create(:user)
        activate_authlogic and UserSession.create(different_account_manager)
        Role.grant_role(Role::ROLE[:account_manager], different_account_manager, Factory.create(:account))

        event = Factory.create(:event)
        get :show, {:id => event.id}
        assigns[:event].should be_nil
        response.should redirect_to(admin_login_path)
      end
    end

    it 'should show event details if user is regional manager'

    it 'should show event details if user is regional manager'

    it 'should be denied for public users' do
      another_user = Factory.create(:user)
      event = Factory(:event, :manager => another_user)

      get :show, {:id => event.id}
      response.should redirect_to(admin_login_path)
    end

    it 'should be denied for event manager' do
      user = Factory.create(:user)
      activate_authlogic and UserSession.create(user)
      event = Factory(:event, :status => Event::STATUS[:new], :manager => user)

      get :show, {:id => event.id}
      response.should redirect_to(admin_login_path)
    end
  end

  describe 'update' do
    it 'should update event if user is account manager'

    it 'should be denied to update event if user is different account manager'

    it 'should update event if user is regional manager'

    it 'should be denied to update event if user is different regional manager'

    it 'should be denied for unauthorized users' do
      user = Factory.create(:user)
      event = Factory(:event, :status => Event::STATUS[:new], :manager => user)
      post :update, {:id => event.url, :event => event.attributes}
      response.should redirect_to(admin_login_path)
    end
  end
end
