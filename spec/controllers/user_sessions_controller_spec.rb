require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserSessionsController, 'login' do

  it 'should not let login users who are not activated' do
    user = Factory(:user_not_activated)
    post :create, {:user_session => {:email => user.email, :password => user.password}}
    response.should render_template(:new)
    flash[:error].should_not be_empty
  end

end

describe UserSessionsController, 'logout' do
  
  it 'should redirect to login view after successful logout' do
    get :destroy
    response.should redirect_to(login_path)
  end
  
end