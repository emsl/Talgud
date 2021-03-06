require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::CountiesController do
  before(:each) do
    @user = Factory.create(:user)
    Role.grant_role(Role::ROLE[:account_manager], @user, Account.current)
  end
  
  describe 'index' do
    it 'should be denied for public users' do
      counties = Array.new(10) { |i| Factory.create(:county) }
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      counties = Array.new(10) { |i| Factory.create(:county) }
      get :index
      assigns[:counties].each { |e| counties.should include(e) }
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
      county = Factory(:county)
      post :create, {:county => county.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      county = Factory(:county)
      post :create, {:county => county.attributes}
      response.should redirect_to(admin_counties_path)
    end
  end
  
  describe 'show' do
    it 'should be denied for public users' do
      county = Factory(:county)
      get :show, {:id => county.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      county = Factory(:county)
      get :show, {:id => county.id}
      response.should be_success      
    end
  end
   
  describe 'edit' do
    it 'should be denied for public users' do
      county = Factory(:county)
      get :edit, {:id => county.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      county = Factory(:county)
      get :edit, {:id => county.id}
      response.should be_success      
    end
  end

  describe 'update' do
    it 'should be denied for public users' do
      county = Factory(:county)
      post :update, {:id => county.id, :county => county.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      county = Factory(:county)
      post :update, {:id => county.id, :county => county.attributes}
      response.should redirect_to(admin_counties_path)      
    end
  end
  
  describe 'destroy' do
    it 'should be denied for public users' do
      county = Factory(:county)
      put :destroy, {:id => county.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      county = Factory(:county)
      put :destroy, {:id => county.id}
      response.should redirect_to(admin_counties_path)
    end
  end
end
