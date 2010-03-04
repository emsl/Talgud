require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::EventTypesController do
  before(:each) do
    @user = Factory.create(:user)
    Role.grant_role(Role::ROLE[:account_manager], @user, Account.current)
  end
  
  describe 'index' do
    it 'should be denied for public users' do
      event_types = Array.new(10) { |i| Factory.create(:event_type) }
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      event_types = Array.new(10) { |i| Factory.create(:event_type) }
      get :index
      assigns[:event_types].each { |e| event_types.should include(e) }
      response.should be_success
    end
  end
  
  describe 'new' do
    it 'should be denied for public users' do
      get :new
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      get :new
      response.should be_success
    end
  end

  describe 'create' do
    it 'should be denied for public users' do
      event_type = Factory(:event_type)
      post :create, {:event_type => event_type.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      event_type = Factory.build(:event_type)
      post :create, {:event_type => event_type.attributes}
      response.should redirect_to(admin_event_types_path)
    end
  end
  
  describe 'show' do
    it 'should be denied for public users' do
      event_type = Factory(:event_type)
      get :show, {:id => event_type.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      event_type = Factory(:event_type)
      get :show, {:id => event_type.id}
      response.should be_success      
    end
  end
   
  describe 'edit' do
    it 'should be denied for public users' do
      event_type = Factory(:event_type)
      get :edit, {:id => event_type.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      event_type = Factory(:event_type)
      get :edit, {:id => event_type.id}
      response.should be_success      
    end
  end

  describe 'update' do
    it 'should be denied for public users' do
      event_type = Factory(:event_type)
      post :update, {:id => event_type.id, :event_type => event_type.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      event_type = Factory(:event_type)
      post :update, {:id => event_type.id, :event_type => event_type.attributes}
      response.should redirect_to(admin_event_types_path)      
    end
  end
  
  describe 'destroy' do
    it 'should be denied for public users' do
      event_type = Factory(:event_type)
      put :destroy, {:id => event_type.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      event_type = Factory(:event_type)
      put :destroy, {:id => event_type.id}
      response.should redirect_to(admin_event_types_path)
    end
  end
end
