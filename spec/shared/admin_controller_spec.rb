describe 'admin controller', :shared => true do
  
  it 'should let only admin users to use this controller' do
    activate_authlogic
    UserSession.create Factory.build(:user)
    
    get :index
    response.should be_success
    
    pending 'Check if only users in admin role can use this controller'
  end
  
  it 'should redirect to home page when user is not in admin role' do
    get :index
    response.should redirect_to(login_path)
  end
end
