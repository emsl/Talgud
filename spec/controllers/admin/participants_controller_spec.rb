require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ParticipantsController do
  describe 'index' do
    before(:each) do
      @ep = Factory(:event_participant)
    end
    
    it 'should be denied for public users and redirect to home' do
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should assign list of participants associated with event to regional manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:regional_manager], manager, @ep.event.location_address_county)

      get :index, {:format => 'html'}
      assigns[:participants].should include(@ep)

      get :index, {:format => 'csv'}
      assigns[:participants].should include(@ep)
      response.content_type.should eql('text/csv')

      get :index, {:format => 'excel'}
      assigns[:participants].should include(@ep)
      response.content_type.should eql('text/csv')

      get :index, {:format => 'xml'}
      response.content_type.should eql('application/xml')
    end

    it 'should be denied to see list of participants associated with event to different regional manager' do
      manager = Factory.create(:user)
      activate_authlogic and UserSession.create(manager)
      Role.grant_role(Role::ROLE[:regional_manager], manager, Factory(:county))

      get :index
      assigns[:participants].should be_nil
    end  
  end
end
