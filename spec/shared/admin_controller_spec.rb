describe 'admin controller', :shared => true do
  
  it 'should redirect to home page when user is not in admin role' do
    get :index
    response.should redirect_to(admin_login_path)
  end
end
