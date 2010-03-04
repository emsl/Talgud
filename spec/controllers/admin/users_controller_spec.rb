require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  before(:each) do
    @session_user = Factory.create(:user)
    Role.grant_role(Role::ROLE[:account_manager], @session_user, Account.current)
  end
  
  describe 'index' do
    it 'should be denied for public users' do
      users = Array.new(10) { |i| Factory.create(:user) }
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@session_user)
      users = Array.new(10) { |i| Factory.create(:user) }
      get :index
      assigns[:users].each { |e| users.should include(e) }
      response.should be_success
    end
  end
  
  describe 'new' do
    it 'should be denied for public users' do
      get :new
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@session_user)
      get :new
      response.should be_success
    end
  end

  describe 'create' do
    it 'should be denied for public users' do
      user = Factory(:user)
      post :create, {:user => user.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@session_user)
      user = Factory(:user)
      post :create, {:user => user.attributes}
      response.should redirect_to(admin_users_path)
    end
  end
  
  describe 'show' do
    it 'should be denied for public users' do
      user = Factory(:user)
      get :show, {:id => user.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@session_user)
      user = Factory(:user)
      get :show, {:id => user.id}
      response.should be_success      
    end
  end
   
  describe 'edit' do
    it 'should be denied for public users' do
      user = Factory(:user)
      get :edit, {:id => user.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@session_user)
      user = Factory(:user)
      get :edit, {:id => user.id}
      response.should be_success      
    end
  end

  describe 'update' do
    it 'should be denied for public users' do
      user = Factory(:user)
      post :update, {:id => user.id, :user => user.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@session_user)
      user = Factory(:user)
      post :update, {:id => user.id, :user => user.attributes}
      response.should redirect_to(admin_users_path)      
    end
  end
  
  describe 'destroy' do
    it 'should be denied for public users' do
      user = Factory(:user)
      put :destroy, {:id => user.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@session_user)
      user = Factory.create(:user)
      put :destroy, {:id => user.id}
      response.should redirect_to(admin_users_path)
    end
  end
end
