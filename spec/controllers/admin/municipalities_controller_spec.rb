require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::MunicipalitiesController do
  # before(:each) do
  #   @user = Factory.create(:user)
  #   Role.grant_role(Role::ROLE[:account_manager], @user, Account.current)
  # end
  # 
  # describe 'index' do
  #   it 'should be denied for public users' do
  #     municipalities = Array.new(10) { |i| Factory.create(:municipality) }
  #     get :index
  #     response.should redirect_to(admin_login_path)
  #   end
  # 
  #   it 'should be accessible for account manager' do
  #     activate_authlogic and UserSession.create(@user)
  #     municipalities = Array.new(10) { |i| Factory.create(:municipality) }
  #     get :index
  #     assigns[:municipalities].each { |e| municipalities.should include(e) }
  #     response.should be_success
  #   end
  # end
  # 
  # describe 'new' do
  #   it 'should be denied for public users' do
  #     get :new
  #     response.should redirect_to(admin_login_path)
  #   end
  #   
  #   it 'should be accessible for account manager' do
  #     activate_authlogic and UserSession.create(@user)
  #     get :new
  #     response.should be_success
  #   end
  # end
  # 
  # describe 'create' do
  #   it 'should be denied for public users' do
  #     county = Factory(:municipality)
  #     post :create, {:municipality => municipality.attributes}
  #     response.should redirect_to(admin_login_path)
  #   end
  #   
  #   it 'should be accessible for account manager' do
  #     activate_authlogic and UserSession.create(@user)
  #     county = Factory(:municipality)
  #     post :create, {:municipality => municipality.attributes}
  #     response.should redirect_to(admin_municipalities_path)
  #   end
  # end
  # 
  # describe 'show' do
  #   it 'should be denied for public users' do
  #     county = Factory(:municipality)
  #     get :show, {:id => municipality.id}
  #     response.should redirect_to(admin_login_path)
  #   end
  #   
  #   it 'should be accessible for account manager' do
  #     activate_authlogic and UserSession.create(@user)
  #     county = Factory(:municipality)
  #     get :show, {:id => municipality.id}
  #     response.should be_success      
  #   end
  # end
  #  
  # describe 'edit' do
  #   it 'should be denied for public users' do
  #     county = Factory(:municipality)
  #     get :edit, {:id => municipality.id}
  #     response.should redirect_to(admin_login_path)
  #   end
  #   
  #   it 'should be accessible for account manager' do
  #     activate_authlogic and UserSession.create(@user)
  #     county = Factory(:municipality)
  #     get :edit, {:id => municipality.id}
  #     response.should be_success      
  #   end
  # end
  # 
  # describe 'update' do
  #   it 'should be denied for public users' do
  #     county = Factory(:municipality)
  #     post :update, {:id => municipality.id, :municipality => municipality.attributes}
  #     response.should redirect_to(admin_login_path)
  #   end
  #   
  #   it 'should be accessible for account manager' do
  #     activate_authlogic and UserSession.create(@user)
  #     county = Factory(:municipality)
  #     post :update, {:id => municipality.id, :municipality => municipality.attributes}
  #     response.should redirect_to(admin_municipalities_path)      
  #   end
  # end
  # 
  # describe 'destroy' do
  #   it 'should be denied for public users' do
  #     county = Factory(:municipality)
  #     put :destroy, {:id => municipality.id}
  #     response.should redirect_to(admin_login_path)
  #   end
  #   
  #   it 'should be accessible for account manager' do
  #     activate_authlogic and UserSession.create(@user)
  #     county = Factory(:municipality)
  #     put :destroy, {:id => municipality.id}
  #     response.should redirect_to(admin_municipalities_path)
  #   end
  # end
end
