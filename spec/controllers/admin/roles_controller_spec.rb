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

    it 'should be accessible for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)
      
      roles = Array.new(10) { |i| Factory.create(:role) }
      get :index
      roles.each { |e| assigns[:roles].should include(e) }
    end

    it 'should be accessible for regional manager' do
      regional_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(regional_manager)
      event = Factory(:event)
      role = Role.grant_role(Role::ROLE[:regional_manager], regional_manager, event.location_address_county)
      role2 = Role.grant_role(Role::ROLE[:regional_manager], regional_manager, Factory(:event).location_address_county)
      get :index
      response.should be_success
      assigns[:roles].should include(role)
      assigns[:roles].should_not include(role2)
    end
  end
  
  describe 'new' do
    it 'should be denied for public users' do
      get :new
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)
      
      role = Factory.build(:role)
      get :new, {:model_type => role.model.class.name, :model_id => role.model.id}
      response.should be_success            
    end
  end

  describe 'create' do
    it 'should be denied for public users' do
      role = Factory(:role)
      post :create, {:role => role.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)

      role = Factory.build(:role)
      post :create, {:role => role.attributes, :model_type => role.model.class.name, :model_id => role.model.id}
      response.should redirect_to(new_admin_role_path(:model_type => assigns[:target_model].class.name, :model_id => assigns[:target_model].id))
    end
  end
  
  describe 'show' do
    it 'should be denied for public users' do
      role = Factory(:role)
      get :show, {:id => role.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)
      
      role = Factory(:role)
      get :show, {:id => role.id}
      response.should redirect_to(admin_login_path)      
    end
  end
   
  describe 'edit' do
    it 'should be denied for public users' do
      role = Factory(:role)
      get :edit, {:id => role.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be denied for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)
      
      role = Factory(:role)
      get :edit, {:id => role.id}
      response.should redirect_to(admin_login_path)
    end    
  end

  describe 'update' do
    it 'should be denied for public users' do
      role = Factory(:role)
      post :update, {:id => role.id, :role => role.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be denied for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)
      
      role = Factory(:role)
      post :update, {:id => role.id, :role => role.attributes}
      response.should redirect_to(admin_login_path)
    end
  end
  
  describe 'destroy' do
    it 'should be denied for public users' do
      role = Factory(:role)
      put :destroy, {:id => role.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      account_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(account_manager)
      Role.grant_role(Role::ROLE[:account_manager], account_manager, Account.current)
      
      role = Factory(:role)
      put :destroy, {:id => role.id, :model_type => role.model.class.name, :model_id => role.model.id}
      response.should redirect_to(new_admin_role_path(:model_type => role.model.class.name, :model_id => role.model.id))  
    end

    it 'should be accessible for regional manager' do
      regional_manager = Factory.create(:user)
      activate_authlogic and UserSession.create(regional_manager)
      event = Factory(:event)
      role = Role.grant_role(Role::ROLE[:regional_manager], regional_manager, event.location_address_county)
      put :destroy, {:id => role.id, :model_type => role.model.class.name, :model_id => role.model.id}
      response.should redirect_to(new_admin_role_path(:model_type => role.model.class.name, :model_id => role.model.id))  
    end

    it 'should be denied for different regional manager' do
      regional_manager = Factory.create(:user)
      regional_manager2 = Factory.create(:user)
      activate_authlogic and UserSession.create(regional_manager)
      event = Factory(:event)
      role = Role.grant_role(Role::ROLE[:regional_manager], regional_manager2, event.location_address_county)      
      role = Role.grant_role(Role::ROLE[:regional_manager], regional_manager, Factory(:event))
      put :destroy, {:id => role.id, :model_type => event.class.name, :model_id => event.id}
      response.should redirect_to(admin_login_path)  
    end
  end
end
