require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::LanguagesController do
  before(:each) do
    @user = Factory.create(:user)
    Role.grant_role(Role::ROLE[:account_manager], @user, Account.current)
  end
  
  describe 'index' do
    it 'should be denied for public users' do
      languages = Array.new(10) { |i| Factory.create(:language) }
      get :index
      response.should redirect_to(admin_login_path)
    end

    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      languages = Array.new(10) { |i| Factory.create(:language) }
      get :index
      assigns[:languages].each { |e| languages.should include(e) }
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
      language = Factory(:language)
      post :create, {:language => language.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      language = Factory.build(:language)
      post :create, {:language => language.attributes}
      response.should redirect_to(admin_languages_path)
    end
  end
  
  describe 'show' do
    it 'should be denied for public users' do
      language = Factory(:language)
      get :show, {:id => language.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      language = Factory(:language)
      get :show, {:id => language.id}
      response.should be_success      
    end
  end
   
  describe 'edit' do
    it 'should be denied for public users' do
      language = Factory(:language)
      get :edit, {:id => language.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      language = Factory(:language)
      get :edit, {:id => language.id}
      response.should be_success      
    end
  end

  describe 'update' do
    it 'should be denied for public users' do
      language = Factory(:language)
      post :update, {:id => language.id, :language => language.attributes}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      language = Factory(:language)
      post :update, {:id => language.id, :language => language.attributes}
      response.should redirect_to(admin_languages_path)      
    end
  end
  
  describe 'destroy' do
    it 'should be denied for public users' do
      language = Factory(:language)
      put :destroy, {:id => language.id}
      response.should redirect_to(admin_login_path)
    end
    
    it 'should be accessible for account manager' do
      activate_authlogic and UserSession.create(@user)
      language = Factory(:language)
      put :destroy, {:id => language.id}
      response.should redirect_to(admin_languages_path)
    end
  end
end
