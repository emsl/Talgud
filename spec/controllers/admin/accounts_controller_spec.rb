require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AccountsController do
  before(:each) do
    @user = Factory.create(:user)
    Role.grant_role(Role::ROLE[:account_manager], @user, Account.current)
  end
  
  describe 'index' do
    it 'should be denied for public users' do
      accounts = Array.new(10) { |i| Factory.create(:account) }
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      accounts = Array.new(10) do |i| 
        Factory.create(:account)
      end
      accounts << Account.current
      
      get :index
      response.should be_success
      assigns[:accounts].each { |e| accounts.should include(e) }
    end
  end
  
  describe 'show' do
    it 'should be denied for public users' do
      account = Factory(:account)
      get :show, {:id => account.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      account = Factory(:account)
      get :show, {:id => account.id}
      response.should be_success      
    end
  end
   
  describe 'edit' do
    it 'should be denied for public users' do
      account = Factory(:account)
      get :edit, {:id => account.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      account = Factory(:account)
      get :edit, {:id => account.id}
      response.should be_success      
    end
  end

  describe 'update' do
    it 'should be denied for public users' do
      account = Factory(:account)
      post :update, {:id => account.id, :account => account.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      account = Factory(:account)
      post :update, {:id => account.id, :account => account.attributes}
      response.should redirect_to(admin_accounts_path)      
    end
  end
end