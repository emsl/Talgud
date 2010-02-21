describe 'admin controller', :shared => true do
  
  it 'should let only admin users to use this controller'
  
  it 'should redirect to home page when user is not in admin role' do
    get :index
    response.should redirect_to(login_path)
  end
end
