require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::RolesController do
  before(:each) do
    @user = Factory.create(:user)
    Role.grant_role(Role::ROLE[:account_manager], @user, Account.current)
  end
  
  describe 'index' do
    it 'should be denied for public users' do
      roles = Array.new(10) { |i| Factory.create(:role) }
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should be accessible for account manager'
  end
  
  describe 'new' do
    it 'should be denied for public users' do
      get :new
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager'
  end

  describe 'create' do
    it 'should be denied for public users' do
      role = Factory(:role)
      post :create, {:role => role.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager'
  end
  
  describe 'show' do
    it 'should be denied for public users' do
      role = Factory(:role)
      get :show, {:id => role.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager'
  end
   
  describe 'edit' do
    it 'should be denied for public users' do
      role = Factory(:role)
      get :edit, {:id => role.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager'
  end

  describe 'update' do
    it 'should be denied for public users' do
      role = Factory(:role)
      post :update, {:id => role.id, :role => role.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager'
  end
  
  describe 'destroy' do
    it 'should be denied for public users' do
      role = Factory(:role)
      put :destroy, {:id => role.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager'
  end
end
